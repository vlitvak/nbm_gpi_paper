function D = nbm_rest_prepare(initials)

%---------------------------------------------------------------------
% Copyright (C) 2020 Wellcome Trust Centre for Neuroimaging

keep = 0;

try
    [files,root, details] = nbm_subjects(initials, 'rest');
catch
    D = [];
    return
end
%%
if ~exist(root, 'dir')
    if ismember(root(end), {'/', '\'})
        root(end) = [];
    end
    [p, p1] = fileparts(root);
    if ~exist(p, 'dir')
        if ismember(p(end), {'/', '\'})
            p(end) = [];
        end
        [p2, p3] = fileparts(p);
        if ~exist(p2, 'dir')
            if ismember(p2(end), {'/', '\'})
                p2(end) = [];
            end
            [p4, p5] = fileparts(p2);
            res = mkdir(p4, p5);
        end
        res = mkdir(p2, p3);
    end
    res = mkdir(p, p1);
end

cd(root);

fD = {};

for f = 1:numel(files)       
    % =============  Conversion =============================================
    source = ft_filetype(files{f});
    
    S = [];
    S.dataset = files{f};
    %S.channels = details.chanset;
    S.checkboundary = 0;   
    S.mode = 'continuous';
    S.outfile = ['spmeeg' num2str(f) '_' spm_file(S.dataset,'basename')];
        
    D = spm_eeg_convert(S);
       
    
    % Montage ========== =============================================
    montage = details.(source).montage;
    
    if ~isempty(montage) 
        
        
        S = [];
        S.D = D;       
        
        S.montage = montage;
        S.keepothers = 0;
        D = spm_eeg_montage(S);
        
        if ~keep, delete(S.D);  end
        
    end
    
    D = chantype(D, D.indchannel(details.chan), 'LFP');
       
    save(D);
    
    S   = [];
    S.D = D;
    S.channels = details.chan;
    D = spm_eeg_crop(S);
    
    if ~keep, delete(S.D);  end
    

    % Downsample =======================================================
    if D.fsample > 350
        
        S = [];
        S.D = D;
        S.fsample_new = 300;
        
        D = spm_eeg_downsample(S);
        
        if ~keep, delete(S.D);  end
    end
     
    
    % Filtering =========================================
    S = [];
    S.D = D;
    S.type = 'butterworth';
    S.band = 'high';
    S.freq = 1;
    S.dir = 'twopass';
    S.order = 5;
    D = spm_eeg_filter(S);
    
    
    if ~keep, delete(S.D);  end
    
    
    S = [];
    S.D = D;
    S.type = 'butterworth';
    S.band = 'stop';
    S.freq = [48 52];
    S.dir = 'twopass';
    S.order = 5;
    
    while S.freq(2)<min(600, (D.fsample/2))
        D = spm_eeg_filter(S);
        if ~keep, delete(S.D);  end
        
        S.D = D;
        S.freq = S.freq+50;
    end
    
    % Epoching =========================================
    S = [];
    S.D = D;
    S.trialength = 1000;
    S.conditionlabels = ['R_' source];        
    S.bc = 0;
    D = spm_eeg_epochs(S);
    
    if ~keep, delete(S.D);  end
    
    % Trial rejection =========================================
    S = [];
    S.D = D;
    S.badchanthresh = 1;
    S.methods(1).channels = details.chan;
    S.methods(1).fun = 'threshchan';
        
    S.methods(1).settings.threshold = details.(source).thresh;    
    
    D = spm_eeg_artefact(S);
    
    % ************ Breakpoint 2
    ind = D.indchantype('LFP');
    figure;plot(D.time, squeeze(D(ind(1), :, :)));
    
    %  details.badchanthresh = 0.02;
    %  S.badchanthresh = details.badchanthresh;
    %  D = spm_eeg_artefact(S);
    
    if ~keep, delete(S.D);  end
    
    
    save(D);
    
    %%
    S   = [];
    S.D = D;   
    fD{f} = spm_eeg_remove_bad_trials(S);
    
    if ~keep && ~isequal(fname(fD{f}), fname(S.D))
        delete(S.D);
    end
end
%%
fD(cellfun('isempty', fD)) = [];

nf = numel(fD);

if numel(fD)>1
    S = [];
    S.D = fname(fD{1});
    for f = 2:numel(fD)
        S.D = strvcat(S.D, fname(fD{f}));
    end
    S.recode = 'same';
    D = spm_eeg_merge(S);
    
    fileind =[];
    for f = 1:numel(fD)
        fileind = [fileind f*ones(1, ntrials(fD{f}))];     
        if ~keep
            delete(fD{f});
        end
    end  
elseif  numel(fD)==1
    D = fD{1};
    fileind = ones(1, ntrials(D));
end

D = trialtag(D, ':', fileind);

%%
D.initials = initials;

save(D);

D = D.move(initials);

S = [];
S.D = D;
S.channels = {'all'};
S.frequencies = 1:100;
S.timewin = [-Inf Inf];
S.phase = 0;
S.method = 'mtmfft';
S.settings.taper = 'hanning';
S.settings.freqres = 1;
S.prefix = '';
D = spm_eeg_tf(S);

S = [];
S.D = D;
S.robust = false;
S.circularise = false;
S.prefix = 'm';
D = spm_eeg_average(S);

if ~keep, delete(S.D);  end

S = [];
S.D = D;
S.method = 'Sqrt';
S.prefix = 'r';
S.timewin = [-Inf 0];
D = spm_eeg_tf_rescale(S);

%if ~keep, delete(S.D);  end