
%---------------------------------------------------------------------
% Copyright (C) 2020 Wellcome Trust Centre for Neuroimaging


clear

subjects_nbm = {'LN_C07', 'LN_C25', 'LN_C26', 'LN_C29', 'LN_C32', 'LN_C33', 'LN_C42', 'LN_C44',  'LN_C47', 'LN_C54'};% 

subjects_pdd =  {'LN_C07', 'LN_C29', 'LN_C32', 'LN_C33', 'LN_C42', 'LN_C44'};

subjects_dlb = setdiff(subjects_nbm, subjects_pdd);

%root = 'C:\home\Data\DBS-MEG';
statdir = 'C:\home\Data\NBM\COH_stats\withinband\';
%statdir = 'C:\home\Data\NBM\COH_stats\NBM';



maskdir = 'C:\home\Data\NBM\COH_stats\4bands\combined';

subjects = subjects_nbm;%subjects_dlb;%subjects_pdd;%

pair =  {'01', '23'};%{'23'};%

bands = {[2 8], [8 13], [13 22], [22 35]};%{[2 13], [13 35]};%{[1 12], [15 25], [30 40], [52 98]};
bandlabels = {'theta', 'alpha', 'lbeta', 'hbeta'};

b = 4;

normsuffix = '';%'us_';%

statdir = fullfile(statdir, [normsuffix bandlabels{b}]);

spm_mkdir(statdir);
%%
matlabbatch{1}.spm.stats.factorial_design.dir = {statdir};
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).name = 'Subject';
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).dept = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).variance = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).name = 'Disease';
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).dept = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).variance = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).name = 'Contact';
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).dept = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).variance = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(4).name = 'Side';
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(4).dept = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(4).variance = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(4).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(4).ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{1}.inter.fnums = [3
    2];

matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {fullfile(maskdir, [bandlabels{b} '_mask.nii'])};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;
matlabbatch{3}.spm.stats.con.spmmat(1) = cfg_dep('Model estimation: SPM.mat File', substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{3}.spm.stats.con.consess{1}.fcon.name = 'Interaction';
matlabbatch{3}.spm.stats.con.consess{1}.fcon.weights = [1 -1 -1 1];
matlabbatch{3}.spm.stats.con.consess{1}.fcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{2}.fcon.name = 'Disease';
matlabbatch{3}.spm.stats.con.consess{2}.fcon.weights = [-1 1 -1 1];
matlabbatch{3}.spm.stats.con.consess{2}.fcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.consess{3}.fcon.name = 'Contact';
matlabbatch{3}.spm.stats.con.consess{3}.fcon.weights = [-1 -1 1 1];
matlabbatch{3}.spm.stats.con.consess{3}.fcon.sessrep = 'none';
matlabbatch{3}.spm.stats.con.delete = 1;
matlabbatch{4}.spm.stats.results.spmmat(1) = cfg_dep('Contrast Manager: SPM.mat File', substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{4}.spm.stats.results.conspec.titlestr = '';
matlabbatch{4}.spm.stats.results.conspec.contrasts = 1;
matlabbatch{4}.spm.stats.results.conspec.threshdesc = 'none';
matlabbatch{4}.spm.stats.results.conspec.thresh = 0.05;
matlabbatch{4}.spm.stats.results.conspec.extent = 0;
matlabbatch{4}.spm.stats.results.conspec.conjunction = 1;
matlabbatch{4}.spm.stats.results.conspec.mask.none = 1;
matlabbatch{4}.spm.stats.results.units = 1;
matlabbatch{4}.spm.stats.results.export{1}.ps = true;

images = {};
factors = [];
for s = 1:numel(subjects)
    initials = subjects{s};
    
    try
        [~, ~, root, details] = dbs_subjects(initials, 1);
    catch
        [~, ~, root, details] = dbs_subjects(initials, 0);
    end
    
    if isequal(details.diagnosis, 'PDD')
        diagnosis = 1;       
    else
        diagnosis = 2;      
    end
        
    banddir = sprintf('band_%d_%dHz', bands{b});
    
    
    for c = 1:numel(details.chan)
        
        cd(fullfile(root, 'SPMrest', banddir, details.chan{c}));
        
        if ismember(details.chan{c}((end-1):end), pair)
            
            if isequal(details.chan{c}((end-1):end), '01')
                contact = 1;
            else
               contact = 2; 
            end
            
            if isequal(details.chan{c}(end-2), 'L')            
                images = [images; {fullfile(pwd, ['sf' normsuffix 'full_orig.nii'])}];
                factors = [factors; s, diagnosis, contact, 2];              
            else
                images = [images; {fullfile(pwd, ['s' normsuffix 'full_orig.nii'])}];
                factors = [factors; s, diagnosis, contact, 1];               
            end
        end
    end

end
%%
for s = 1:numel(subjects)
    ind = find(factors(:, 1)==s);
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(s).scans = images(ind);
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(s).conds = factors(ind, 2:end);
end

spm_jobman('run', matlabbatch);

cd(statdir);

return


