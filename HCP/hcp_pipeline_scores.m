%% Grab HCP preproc for scores analysis
clear all
exp = 'niak_preproc';
tst = '_task-specific_prior'
task = 'MOTOR';
path_root = ['/home/yassinebha/database/HCP/'];
path_preproc = [path_root 'fmri_preprocess_' task '_niak' ];

%%%%%%% Uncomment this section if you want to use cambridge template %%%%%%%%%%%%%%%%%
%% Get the cambridge templates
%template.path = [path_preproc '/anat/template_cambridge_basc_multiscale_mnc_sym' ];
%template.type =  'cambridge_template_mnc';
%niak_wget(template);
%% Select a specific scale for template
%scale = 7 ;
%template_name = sprintf('template_cambridge_basc_multiscale_sym_scale%03d.mnc.gz',scale);
%system([' cp -r ' template.path filesep template_name ' ' path_preproc '/anat/']);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%temporary tweak, for further uses change the fmri grabber
template_name= 'template_cambridge_basc_partition_consensus_group_sci10_scg7_scf7.mnc.gz';
system(['cp -r '  path_root 'basc_MOTOR_niak/stability_group/sci10_scg7_scf7/brain_partition_consensus_group_sci10_scg7_scf7.mnc.gz ' path_preproc '/anat/' template_name]);


%% Grab the results from the NIAK fMRI preprocessing pipeline
opt_g.min_nb_vol = 100;     % The minimum number of volumes for an fMRI dataset to be included. This option is useful when scrubbing is used, and the resulting time series may be too short.
opt_g.min_xcorr_func = 0.34; % The minimum xcorr score for an fMRI dataset to be included. This metric is a tool for quality control which assess the quality of non-linear coregistration of functional images in stereotaxic space. Manual inspection of the values during QC is necessary to properly set this threshold.
opt_g.max_translation = 3 ; % the maximal transition (difference between two adjacent volumes) in translation motion parameters within-run (in mm)
opt_g.max_rotation = 3 ; % the maximal transition (difference between two adjacent volumes) in rotation motion parameters within-run (in degrees)
opt_g.type_files = 'scores'; % Specify to the grabber to prepare the files for the stability FIR pipeline
files_in = niak_grab_fmri_preprocess(path_preproc,opt_g);

% Resample the 3mm cambridge template to 2mm
%files_in_resamp.source =  [path_preproc '/anat/' template_name] ;
%files_in_resamp.target = files_in.mask;
%files_out_resamp       = files_in_resamp.source;
%opt_resamp.interpolation      = 'nearest_neighbour';
%niak_brick_resample_vol (files_in_resamp,files_out_resamp,opt_resamp);

%% Set pipeline options
opt.folder_out = [ '/home/yassinebha/scratch/HCP/stability_scores_' task '_' exp tst]; % Where to store the results
opt.flag_vol = true;

%% Generate the pipeline
opt.psom.max_queued = 300;
[pipeline, opt_scores] = niak_pipeline_scores(files_in,opt);

%%extra
system(['cp ' mfilename('fullpath') '.m ' opt.folder_out '/.']); % make a copie of this script to output folder