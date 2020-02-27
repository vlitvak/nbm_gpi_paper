
%---------------------------------------------------------------------
% Copyright (C) 2020 Wellcome Trust Centre for Neuroimaging


subjects = {'LN_C07', 'LN_C25', 'LN_C26', 'LN_C29', 'LN_C32', 'LN_C33', 'LN_C42', 'LN_C44', 'LN_C47', 'LN_C54', 'DLB3'};


contacts = {'LFP_R01', 'LFP_L01';...
    'LFP_R12', 'LFP_L12';...
    'LFP_R23', 'LFP_L23'};

alldata = [];
diagnosis = [];

settings = fooof_check_settings([]);
settings.peak_width_limits = [4 10];
settings.background_mode = 'knee';
settings.max_n_peaks = Inf;
settings.peak_threshold = 2;

f_range = [5, 95];

noln = [1:46 54:100];

repl = zeros(numel(subjects), 2);

for n = 1:3
    
    labels = {};
    
    fdata = [];
    % load data
    for s = 1:numel(subjects)
        initials = subjects{s};
        
        [files, root, details] = nbm_subjects(initials, 'rest');
        
        if isequal(initials, 'DLB3')
            details1.diagnosis = 'DLB';
        else
            
            try
                [~, ~, ~, details1] = dbs_subjects(subjects{s}, 1);
                drug = 1;
            catch
                [~, ~, ~, details1] = dbs_subjects(subjects{s}, 0);
                drug = 0;
            end
        end
        
        if n==1
            diagnosis = [diagnosis [1 1]*isequal(details1.diagnosis, 'PDD')];
        end
        
        D = spm_eeg_load(fullfile(root, ['mtf_' initials '.mat']));
        
        freq = D.frequencies;
        
        clabels = D.chanlabels(D.indchannel(contacts(n, :)));
        labels = [labels; repmat({initials}, numel(clabels), 1), clabels(:)];
               
        for c = 1:numel(clabels)
            cdata = [];
            for d = 1:D.ntrials
                pow = D(D.indchannel(clabels(c)), :, :, d);
                pow = interp1(freq(noln), pow(noln), freq);
                
                fooof_results = fooof(freq, pow(:)', f_range, settings, true);
                
                ffreq = fooof_results.freqs;
                
%                 fooof_plot(fooof_results);
%                 
%                 keyboard
%                 close(gcf)
                
                
                cdata = [cdata; fooof_results.power_spectrum-fooof_results.bg_fit];
            end
            
            if size(cdata, 1)>1
%                 figure;plot(ffreq, cdata)
%                 keyboard
%                 close(gcf)
                fdata = [fdata; D.repl*cdata./sum(D.repl)];
                
                repl(s, :) = D.repl;
            else
                fdata = [fdata; cdata];
                
                switch char(D.conditions)
                    case 'R_brainvision_vhdr'
                        repl(s, 1) = D.repl;
                    case 'R_ced_spike6mat'
                        repl(s, 2) = D.repl;
                end
            end
        end
        
        alldata(n).labels = labels;
        
        alldata(n).fdata = fdata;        
    end
end
%%


%%
figure;
for n = 1:3
    plot(ffreq, mean(alldata(n).fdata));
    hold on
end
xlim([2 45]);
%%
% Look at difference between GP and NBM
difference = alldata(3).fdata-alldata(1).fdata;
ns = size(difference, 1);
%%
figure
subplot(2,2,1);


fs = 20;

k = 1;
shadedErrorBar(ffreq, squeeze(mean(alldata(k).fdata(~~diagnosis, :), 1)), squeeze(std(alldata(k).fdata(~~diagnosis, :), [], 1))./sqrt(sum(diagnosis)),{ 'm--', 'LineWidth', 2});
hold on
shadedErrorBar(ffreq, squeeze(mean(alldata(k).fdata(~diagnosis, :), 1)), squeeze(std(alldata(k).fdata(~diagnosis, :), [], 1))./sqrt(sum(~diagnosis)), {'k-', 'LineWidth', 2});
xlim([5 45]);
set(gca, 'FontSize', fs)

subplot(2,2,2);
k = 3;
shadedErrorBar(ffreq, squeeze(mean(alldata(k).fdata(~~diagnosis, :), 1)), squeeze(std(alldata(k).fdata(~~diagnosis, :), [], 1))./sqrt(sum(diagnosis)), {'m--', 'LineWidth', 2});
hold on
shadedErrorBar(ffreq, squeeze(mean(alldata(k).fdata(~diagnosis, :), 1)), squeeze(std(alldata(k).fdata(~diagnosis, :), [], 1))./sqrt(sum(~diagnosis)), { 'k-', 'LineWidth', 2});
xlim([5 45]);
set(gca, 'FontSize', fs)

subplot(2,2,3);
plot(ffreq, squeeze(mean(alldata(1).fdata(~~diagnosis, :), 1)), 'k-', 'LineWidth', 2);
hold on
plot(ffreq, squeeze(mean(alldata(3).fdata(~~diagnosis, :), 1)), 'k--', 'LineWidth', 2);

difference =  squeeze(alldata(3).fdata(~~diagnosis, :) - alldata(1).fdata(~~diagnosis, :));

shadedErrorBar(ffreq, mean(difference), 1.96*std(difference)./sqrt(sum(diagnosis)), 'k-');
plot(ffreq, 0*ffreq, 'k:', 'LineWidth', 2);
xlim([5 45]);
set(gca, 'FontSize', fs)

subplot(2,2,4);
plot(ffreq, squeeze(mean(alldata(1).fdata(~diagnosis, :), 1)), 'k-', 'LineWidth', 2);
hold on
plot(ffreq, squeeze(mean(alldata(3).fdata(~diagnosis, :), 1)), 'k--', 'LineWidth', 2);

difference =  squeeze(alldata(3).fdata(~diagnosis, :) - alldata(1).fdata(~diagnosis, :));

shadedErrorBar(ffreq, mean(difference), 1.96*std(difference)./sqrt(sum(~diagnosis)), 'k-');

plot(ffreq, 0*ffreq, 'k:', 'LineWidth', 2);
xlim([5 45]);
set(gca, 'FontSize', fs)
%%
