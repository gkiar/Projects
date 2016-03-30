%%% script based on :
%%% Angela Tam's on github: mcinet/mcinet_pipeline_BASC_regular_grid.m
%%% Pierre Bellec & SIMEXP team, 2016, CRIUGM

clear all
path_niak = ('/gs/project/gsf-624-aa/quarantaine/niak-issue100/');
addpath(genpath(path_niak))

%guillimin
path_data = '/home/perrine/scratch/RANN/';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Setting input/output files %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

files_in = niak_grab_region_growing([path_data 'BASC-4_task_synant/rois/']);
files_in.infos = [path_data 'GLM_synant.csv']; % A file of comma-separeted values describing additional information on the subjects, this can be omitted

%%%%%%%%%%%%%
%% Options %%
%%%%%%%%%%%%% 
opt_g.min_nb_vol = 60;     % The minimum number of volumes for an fMRI dataset to be included. This option is useful when scrubbing is used, and the resulting time series may be too short.
opt.folder_out = [path_data 'MSTEPS_synant']; % Where to store the results
opt.grid_scales = 5:5:200; % Search for stable clusters in the range 5 to 200
% opt.scales_maps = repmat(opt.grid_scales,[1 3]); % The scales that will be used to generate the maps of brain clusters and stability. 
%                                                  % In this example the same number of clusters are used at the individual (first column), 
%                                                  % group (second column) and consensus (third and last colum) levels.
opt.scales_maps = [10 7 7;...
 20 16 18;...
 40 32 32;...
 70 70 71;...
 120 132 139;...
 200 220 220;...
 320 320 316;...
 440 484 422];

opt.stability_tseries.nb_samps = 100; % Number of bootstrap samples at the individual level. 100: the CI on indidividual stability is +/-0.1
opt.stability_group.nb_samps = 1000; % Number of bootstrap samples at the group level. 500: the CI on group stability is +/-0.05

opt.flag_ind = true;   % Generate maps/time series at the individual level
opt.flag_mixed = true; % Generate maps/time series at the mixed level (group-level networks mixed with individual stability matrices).
opt.flag_group = true;  % Generate maps/time series at the group level

%%%%%%%%%%%%%%%%%%%%%%
%% Run the pipeline %%
%%%%%%%%%%%%%%%%%%%%%%
opt.flag_test = false; % Put this flag to true to just generate the pipeline without running it. Otherwise the region growing will start. 

opt.psom.max_queued              =  304;       % Number of jobs that can run in parallel. In batch mode, this is usually the number of cores.
opt.time_between_checks = 60;
opt.psom.nb_resub = Inf; %verbose opt
opt.psom.qsub_options = '-A gsf-624-aa -q sw -l nodes=1:ppn=2,pmem=3700m,walltime=36:00:00'; %so that workers stop beeing killed by walltime after 3h
pipeline = niak_pipeline_stability_rest(files_in,opt); 