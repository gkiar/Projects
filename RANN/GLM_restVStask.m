%%% 
% based on demo GLM CONNECTOME SCRIPT and Pierre Orban's workshop (CRIUGM) may 2014
% adapted to continuous variable
% SIMEXP - Pierre Bellec

clear all
path_niak = ('/gs/project/gsf-624-aa/quarantaine/niak-issue100/')
addpath(genpath(path_niak))
path_data = '/gs/project/gsf-624-aa/RANN/'; %% GUILLIMIN
%%% path_data = '/home/pferr/RANN/'; %% MAGMA 

%%%%%%%%%%%%
%% Grabbing the results from BASC: tasks to compare with task state (if we want a more general/stable? template, we could run BASC with task+rest, or (better): cambridge templates!
%%%%%%%%%%%%
files_in = niak_grab_stability_rest([path_data 'RANNbackup/RANN_MSTEPS_rest_and_tasks']); 

%%%%%%%%%%%%%%%%%%%%%
%% Grabbing the results from the NIAK fMRI preprocessing pipeline
%%%%%%%%%%%%%%%%%%%%%
opt_g.min_nb_vol = 60; % The minimum number of volumes for an fMRI dataset to be included. This option is useful when scrubbing is used, and the resulting time series may be too short.
opt_g.min_xcorr_func = 0; % The minimum xcorr score for an fMRI dataset to be included. This metric is a tool for quality control which assess the quality of non-linear coregistration of functional images in stereotaxic space. Manual inspection of the values during QC is necessary to properly set this threshold.
opt_g.min_xcorr_anat = 0; % The minimum xcorr score for an fMRI dataset to be included. This metric is a tool for quality control which assess the quality of non-linear coregistration of the anatomical image in stereotaxic space. Manual inspection of the values during QC is necessary to properly set this threshold.
opt_g.type_files = 'glm_connectome'; % Specify to the grabber to prepare the files for the glm_connectome pipeline
% opt_g.filter.session = {'session1'}; % Just grab session 1

%% select one task or another:
%opt_g.filter.run = {'rest'}
%opt_g.filter.run = {'syn'}
%opt_g.filter.run = {'ant'}

%% participants excluded to obtain an FD match between age groups <50yo> and same N of participants in each age group
%% exclude subjects syn:
%opt_g.exclude_subject = {'P00004840_session1_syn','P00002012_session1_syn', 'P00004654_session1_syn','P00004663_session1_syn','P00004694_session1_syn','P00004742_session1_syn','P00004743_session1_syn','P00004501_session1_syn','P00004551_session1_syn','P00004571_session1_syn','P00004636_session1_syn','P00004648_session1_syn','P00004719_session1_syn','P00004787_session1_syn','P00004797_session1_syn','P00004805_session1_syn','P00004825_session1_syn','P00004828_session1_syn'}
%%exclude subjects antonyms:
%opt_g.exclude_subject = {'P00004663_session1_ant','P00004694_session1_ant','P00004636_session1_ant','P00004743_session1_ant','P00004654_session1_ant','P00004819_session1_ant','P00004873_session1_ant','P00004239_session1_ant','P00004687_session1_ant','P00004639_session1_ant','P00004574_session1_ant','P00004656_session1_ant','P00004816_session1_ant','P00004742_session1_ant','P00004877_session1_ant','P00004731_session1_ant','P00004306_session1_ant','P00004721_session1_ant','P00004246_session1_ant','P00004549_session1_ant','P00004617_session1_ant','P00004794_session1_ant','P00004209_session1_ant'}
%%exclude subjects rest to idealy match <50yo>:
%opt_g.exclude_subject = {'P00004847_session1_rest','P00004829_session1_rest','P00004551_session1_rest','P00004537_session1_rest', 'P00004694_session1_rest','P00004654_session1_rest', 'P00004501_session1_rest', 'P00004719_session1_rest','P00004663_session1_rest', 'P00004687_session1_rest', 'P00004819_session1_rest','P00004657_session1_rest', 'P00004587_session1_rest', 'P00004742_session1_rest', 'P00004646_session1_rest', 'P00004835_session1_rest', 'P00004545_session1_rest', 'P00004735_session1_rest', 'P00004797_session1_rest', 'P00004809_session1_rest', 'P00004502_session1_rest', 'P00004675_session1_rest', 'P00004691_session1_rest', 'P00004757_session1_rest', 'P00004560_session1_rest', 'P00004689_session1_rest', 'P00004209_session1_rest', 'P00004724_session1_rest', 'P00004840_session1_rest', 'P00004630_session1_rest', 'P00004708_session1_rest', 'P00004356_session1_rest', 'P00004894_session1_rest', 'P00004802_session1_rest', 'P00004304_session1_rest', 'P00004703_session1_rest', 'P00004686_session1_rest', 'P00004577_session1_rest', 'P00004810_session1_rest', 'P00004261_session1_rest'}
%%exclude subjects rest with no BEHAV data (according to logs):
%opt_g.exclude_subject = {'P00004217_session1_rest','P00004233_session1_rest','P00004242_session1_rest','P00004252_session1_rest','P00004505_session1_rest','P00004516_session1_rest','P00004520_session1_rest','P00004524_session1_rest','P00004528_session1_rest','P00004530_session1_rest','P00004532_session1_rest','P00004537_session1_rest','P00004538_session1_rest','P00004540_session1_rest','P00004563_session1_rest','P00004570_session1_rest','P00004627_session1_rest','P00004657_session1_rest','P00004700_session1_rest','P00004703_session1_rest','P00004708_session1_rest','P00004733_session1_rest','P00004736_session1_rest','P00004759_session1_rest','P00004778_session1_rest','P00004780_session1_rest','P00004790_session1_rest','P00004804_session1_rest','P00004807_session1_rest','P00004809_session1_rest','P00004810_session1_rest','P00004846_session1_rest','P00004847_session1_rest'}

%%exclude subjects rest with behav task missing ANT (according to spss files):
%opt_g.exclude_subject = {'P00004233_session1_rest','P00004532_session1_rest','P00004537_session1_rest','P00004538_session1_rest','P00004563_session1_rest','P00004700_session1_rest','P00004736_session1_rest','P00004759_session1_rest','P00004778_session1_rest','P00004780_session1_rest','P00004809_session1_rest','P00004356_session1_rest','P00004528_session1_rest','P00004540_session1_rest','P00004627_session1_rest','P00004790_session1_rest','P00004847_session1_rest'}

%%exclude subjects rest with behav task missing SYN:
%opt_g.exclude_subject = {'P00004233_session1_rest','P00004532_session1_rest','P00004537_session1_rest','P00004538_session1_rest','P00004563_session1_rest','P00004656_session1_rest','P00004666_session1_rest','P00004687_session1_rest','P00004700_session1_rest','P00004736_session1_rest','P00004759_session1_rest','P00004778_session1_rest','P00004780_session1_rest','P00004809_session1_rest','P00004356_session1_rest','P00004528_session1_rest','P00004540_session1_rest','P00004627_session1_rest','P00004790_session1_rest','P00004847_session1_rest','P00004874_session1_rest','P00004528_session1_rest','P00004540_session1_rest','P00004627_session1_rest','P00004782_session1_rest','P00004790_session1_rest','P00004794_session1_rest','P00004847_session1_rest'}


files_in.fmri = niak_grab_fmri_preprocess([path_data 'RANNbackup/FINAL_preprocess_test_issue100_16.03.03'],opt_g).fmri; % Replace the folder by the path where the results of the fMRI preprocessing pipeline were stored. 

%%%%%%%%%%%%
%% Set the model
%%%%%%%%%%%%

%% Group:  model_group 
files_in.model.group = [path_data 'Models/model_group_161127.csv']
%%%%%%%%

%% inter_run: model_interrun
subject_id = fieldnames(files_in.fmri);
for n = 1:length(subject_id)
    files_in.model.individual.(subject_id{n}).inter_run = [path_data 'Models/model_interrun_all_tasks_161116.csv'];
end

%%2d trial:
%for n=1:length(subjects_list);    %%  IDs de sujets dans ton model de groupe
%files_in.model.individual.(subjects_list{n}).inter_run = [path_data 'BEHAV_all_filters_ant_syn.csv'];
%end


%%%%%%%%%%%%
%% Options 
%%%%%%%%%%%%
opt.folder_out = [path_data 'RANNbackup/RANN_GLMconnectome/GLM_restVStask_test_161127']; % Where to store the resultsb
opt.fdr = 0.1; % The maximal false-discovery rate that is tolerated both for individual (single-seed) maps and whole-connectome discoveries, at each particular scale (multiple comparisons across scales are addressed via permutation testing)
opt.fwe = 0.05; % The overall family-wise error, i.e. the probablity to have the observed number of discoveries, agregated across all scales, under the global null hypothesis of no association.
opt.nb_samps = 1000; % The number of samples in the permutation test. This number has to be multiplied by OPT.NB_BATCH below to get the effective number of samples
opt.nb_batch = 10; % The permutation tests are separated into NB_BATCH independent batches, which can run on parallel if sufficient computational resources are available
opt.flag_rand = false; % if the flag is false, the pipeline is deterministic. Otherwise, the random number generator is initialized based on the clock for each job.


%%%%%%%%%%%%
%% Tests
%%%%%%%%%%%%

%% 1- rest (4) vs task ant (1)
%% 2- rest (4) vs task syn (2)
%% 3- task ant (1) vs syn (2) 

%%%%% MAIN EFFECTS OF AGE DEPENDING ON TASK %%%%%

%% 1- rest (4) vs task ant (1)
opt.test.age_task4vs1.group.contrast.age = 1 % define contrast of interest (age continuous only)
opt.test.age_task4vs1.group.contrast.education = 0; % regress out confounding variable
opt.test.age_task4vs1.group.contrast.genderFM = 0; % regress out confounding variable
opt.test.age_task4vs1.group.contrast.FD_restXant = 0; % regress out confounding variable
opt.test.age_task4vs1.inter_run.select(1).label = 'task4vs1';
opt.test.age_task4vs1.inter_run.select(1).values = [1 0];
opt.test.age_task4vs1.inter_run.contrast.task4vs1 = 1;

%% 2- rest (4) vs task syn (2)
opt.test.age_task4vs2.group.contrast.age = 1 % define contrast of interest (age continuous only)
opt.test.age_task4vs2.group.contrast.education = 0; % regress out confounding variable
opt.test.age_task4vs2.group.contrast.genderFM = 0; % regress out confounding variable
opt.test.age_task4vs2.group.contrast.FD_restXsyn = 0; % regress out confounding variable
opt.test.age_task4vs2.inter_run.select(1).label = 'task4vs2';
opt.test.age_task4vs2.inter_run.select(1).values = [1 0];
opt.test.age_task4vs2.inter_run.contrast.task4vs2 = 1;

%% 3- rest (4) vs pictname (3)
opt.test.age_task4vs3.group.contrast.age = 1 % define contrast of interest (age continuous only)
opt.test.age_task4vs3.group.contrast.education = 0; % regress out confounding variable
opt.test.age_task4vs3.group.contrast.genderFM = 0; % regress out confounding variable
opt.test.age_task4vs2.group.contrast.FD_restXpictname = 0; % regress out confounding variable
opt.test.age_task4vs3.inter_run.select(1).label = 'task4vs3';
opt.test.age_task4vs3.inter_run.select(1).values = [1 0];
opt.test.age_task4vs3.inter_run.contrast.task4vs3 = 1;


%% 3- task syn (2) vs ant (1) 
%opt.test.age_task2vs1.group.contrast.age = 1 % define contrast of interest (age continuous only)
%opt.test.age_task2vs1.group.contrast.education = 0; % regress out confounding variable
%opt.test.age_task2vs1.group.contrast.genderFM = 0; % regress out confounding variable
%opt.test.age_task2vs1.group.contrast.FD_scrubbed = 0; % regress out confounding variable
%opt.test.age_task2vs1.inter_run.select(1).label = 'task2vs1';
%opt.test.age_task2vs1.inter_run.select(1).values = [1 0];
%opt.test.age_task2vs1.inter_run.contrast.task2vs1 = 1;

%%%%% MAIN EFFECTS OF EDU DEPENDING ON TASK %%%%%

%% 1- rest (4) vs task ant (1)
%opt.test.edu_task4vs1.group.contrast.education = 1 % define contrast of interest (age continuous only)
%opt.test.edu_task4vs1.group.contrast.age = 0; % regress out confounding variable
%opt.test.edu_task4vs1.group.contrast.genderMF = 0; % regress out confounding variable
%opt.test.edu_task4vs1.group.contrast.FD_scrubbed = 0; % regress out confounding variable
%opt.test.edu_task4vs1.inter_run.select(1).label = 'task4vs1';
%opt.test.edu_task4vs1.inter_run.select(1).values = [1 -1];
%opt.test.edu_task4vs1.inter_run.contrast.task4vs1 = 1;

%% 2- rest (4) vs task syn (2)
%opt.test.edu_task4vs2.group.contrast.education = 1 % define contrast of interest (age continuous only)
%opt.test.edu_task4vs2.group.contrast.age = 0; % regress out confounding variable
%opt.test.edu_task4vs2.group.contrast.genderMF = 0; % regress out confounding variable
%opt.test.edu_task4vs2.group.contrast.FD_scrubbed = 0; % regress out confounding variable
%opt.test.edu_task4vs2.inter_run.select(1).label = 'task4vs2';
%opt.test.edu_task4vs2.inter_run.select(1).values = [1 -1];
%opt.test.edu_task4vs2.inter_run.contrast.task4vs2 = 1;

%% 3- task ant (1) vs syn (2) 
%opt.test.edu_task1vs2.group.contrast.edu = 1 % define contrast of interest (age continuous only)
%opt.test.edu_task1vs2.group.contrast.age = 0; % regress out confounding variable
%opt.test.edu_task1vs2.group.contrast.genderMF = 0; % regress out confounding variable
%opt.test.edu_task1vs2.group.contrast.FD_scrubbed = 0; % regress out confounding variable
%opt.test.edu_task1vs2.inter_run.select(1).label = 'task1vs2';
%opt.test.edu_task1vs2.inter_run.select(1).values = [1 -1];
%opt.test.edu_task1vs2.inter_run.contrast.task1vs2 = 1;


%%%%% INTERACTION %%%%%

%%% (unprepared for the task at hand) INTER AGExEDU
%opt.test.interaction_age_edu.group.interaction.label = 'inter_agexedu'
%opt.test.interaction_age_edu.group.interaction.factor = {'age','education'}
%opt.test.interaction_age_edu.group.contrast.age = 0; % define contrast of interest (age continuous only)
%opt.test.interaction_age_edu.group.contrast.education = 0; % regress out confounding variable
%opt.test.interaction_age_edu.group.contrast.genderMF = 0; % regress out confounding variable
%opt.test.interaction_age_edu.group.contrast.FD_rest = 0; % regress out confounding variable
%opt.test.interaction_age_edu.group.contrast.inter_agexedu = 1;
%opt.test.interaction_age_edu.group.select(1).label = 'filter_in_rest'; % select only a task (filtered on FD and perf criteria)
%opt.test.interaction_age_edu.group.select(1).values = 1;




%%%%%%%%%%%%
%% Run the pipeline
%%%%%%%%%%%%
opt.flag_test = false; % Put this flag to true to just generate the pipeline without running it. Otherwise the region growing will start.
opt.psom.max_queued =  290;       % Number of jobs that can run in parallel. In batch mode, this is usually the number of cores.
opt.time_between_checks = 90;
opt.psom.nb_resub = 3;  %verbose opt
opt.psom.qsub_options = '-A gsf-624-aa -q sw -l nodes=1:ppn=3,pmem=3700m,walltime=36:00:00'; %so that workers stop beeing killed by walltime after 36h

[pipeline,opt] = niak_pipeline_glm_connectome(files_in,opt);
