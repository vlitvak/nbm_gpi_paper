
%---------------------------------------------------------------------
% Copyright (C) 2020 Wellcome Trust Centre for Neuroimaging


clear

subjects_nbm = {'LN_C07', 'LN_C25', 'LN_C26', 'LN_C29', 'LN_C32', 'LN_C33', 'LN_C42', 'LN_C44',  'LN_C47', 'LN_C54'};% 

subjects_pdd =  {'LN_C07', 'LN_C29', 'LN_C32', 'LN_C33', 'LN_C42', 'LN_C44'};

subjects_dlb = setdiff(subjects_nbm, subjects_pdd);


statdir = 'C:\home\Data\NBM\COH_stats\NBM';

subjects = subjects_nbm;

pair =  {'01', '12', '23'};

bands = {[2 8], [8 13], [13 22], [22 35]};

spm_mkdir(statdir);
%%
matlabbatch{1}.spm.stats.factorial_design.dir = {statdir};
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).name = 'Subject';
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).dept = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).variance = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(1).ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).name = 'Disease';
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).dept = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).variance = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(2).ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).name = 'Band';
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).dept = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).variance = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(3).ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(4).name = 'Side';
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(4).dept = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(4).variance = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(4).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(4).ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(5).name = 'Orig/Shuff';
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(5).dept = 1;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(5).variance = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(5).gmsca = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.fac(5).ancova = 0;
matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{1}.inter.fnums = [3
    2];
matlabbatch{1}.spm.stats.factorial_design.des.fblock.maininters{2}.inter.fnums = [1
    4];

matlabbatch{1}.spm.stats.factorial_design.cov = struct('c', {}, 'cname', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.multi_cov = struct('files', {}, 'iCFI', {}, 'iCC', {});
matlabbatch{1}.spm.stats.factorial_design.masking.tm.tm_none = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.im = 1;
matlabbatch{1}.spm.stats.factorial_design.masking.em = {''};
matlabbatch{1}.spm.stats.factorial_design.globalc.g_omit = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.gmsca.gmsca_no = 1;
matlabbatch{1}.spm.stats.factorial_design.globalm.glonorm = 1;
matlabbatch{2}.spm.stats.fmri_est.spmmat(1) = cfg_dep('Factorial design specification: SPM.mat File', substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}), substruct('.','spmmat'));
matlabbatch{2}.spm.stats.fmri_est.write_residuals = 0;
matlabbatch{2}.spm.stats.fmri_est.method.Classical = 1;

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
    
    for b = 1:numel(bands)
        banddir = sprintf('band_%d_%dHz', bands{b});
        
        
        for c = 1:numel(details.chan)
           
            cd(fullfile(root, 'SPMrest', banddir, details.chan{c}));
            
            if ismember(details.chan{c}((end-1):end), pair)
                if isequal(details.chan{c}(end-2), 'L')
                    flip_images({'full_orig.nii', 'full_shuffled.nii'});
                    images = [images; {fullfile(pwd, 'ffull_orig.nii')}];
                    factors = [factors; s, diagnosis, b, c, 2, 1];
                    images = [images; {fullfile(pwd, 'ffull_shuffled.nii')}];
                    factors = [factors; s, diagnosis, b, c, 2, 2];
                else
                    images = [images; {fullfile(pwd, 'full_orig.nii')}];
                    factors = [factors; s, diagnosis, b, c, 1, 1];
                    images = [images; {fullfile(pwd, 'full_shuffled.nii')}];
                    factors = [factors; s, diagnosis, b, c, 1, 2];
                end
            end
        end
    end
end

smooth{1}.spm.spatial.smooth.data = images;
smooth{1}.spm.spatial.smooth.fwhm = [16 16 16];
smooth{1}.spm.spatial.smooth.dtype = 0;
smooth{1}.spm.spatial.smooth.im = 1;
smooth{1}.spm.spatial.smooth.prefix = 's';

spm_jobman('run', smooth);

for i = 1:numel(images)
    images{i} = spm_file(images{i}, 'prefix', 's');
end
%%
for s = 1:numel(subjects)
    ind = find(factors(:, 1)==s & factors(:, 6)==1);
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(s).scans = images(ind);
    matlabbatch{1}.spm.stats.factorial_design.des.fblock.fsuball.fsubject(s).conds = factors(ind, [2 3 5 6]);
end

spm_jobman('run', matlabbatch);

cd(statdir);

return
