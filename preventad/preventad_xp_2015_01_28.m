clear

num_net = 7;
path_data = '/home/pbellec/database/preventad/scores_2015_01_28/';
path_res = [path_data 'cluster_' num2str(num_net) 'R_diff' filesep];

%% Load data
file_stack = [path_data,'netstack_net',num2str(num_net),'.nii.gz'];
[hdr,stab] = niak_read_vol(file_stack);
[hdr,mask] = niak_read_vol([path_data 'mask.nii.gz']);
tseries = niak_vol2tseries(stab,mask);

%% correct for the mean
tseries_ga = niak_normalize_tseries(tseries,'mean');
%tseries_ga = tseries;

%% Run a cluster analysis on the demeaned maps
R = corr(tseries_ga');
hier = niak_hierarchical_clustering(R);
part = niak_threshold_hierarchy(hier,struct('thresh',7));
order = niak_part2order (part,R);

%% Visualize the matrices
figure
%opt_vr.limits = [-0.5 0.5];
opt_vr.limits = [-0.3 0.3];
niak_visu_matrix(R(order,order),opt_vr);
figure
opt_p.flag_labels = true;
niak_visu_part(part(order),opt_p);

%% Build loads
avg_clust = zeros(max(part),size(tseries_ga,2));
weights = zeros(size(tseries_ga,1),max(part));
for cc = 1:max(part)
    avg_clust(cc,:) = mean(tseries_ga(part==cc,:),1);
    weights(:,cc) = corr(tseries_ga',avg_clust(cc,:)');
end

%% Load phenotypic variables
[tab,lx,ly] = niak_read_csv([path_data 'model_preventad_20141215.csv']);
load([path_data 'list_subject.mat']);
tab2 = zeros(length(list_subject),size(tab,2));
for ss = 1:length(list_subject)
    ind_s = find(ismember(lx,list_subject{ss}));
    tab2(ss,:) = tab(ss,:);
end

%% GLM analysis 
%list_cov = [5 9 11 13];
%list_cov = [1 2 5 9 13];
list_cov = [5];
%list_cov = 1:14;
%list_cov = [5 6 7 8 9 11 12 13];
pce = zeros(length(list_cov),max(part));
for cc = 1:length(list_cov)
    covar = tab2(:,list_cov(cc));
    fd = tab2(:,15);
    mask_covar = ~isnan(covar);
    %mask_covar = ~isnan(covar)&(tab2(:,2)~=1);
    %model_covar.x = [ones(sum(mask_covar),1) niak_normalize_tseries([covar(mask_covar) fd(mask_covar)],'mean')];
    model_covar.x = [ones(sum(mask_covar),1) niak_normalize_tseries([covar(mask_covar)],'mean')];
    model_covar.y = weights(mask_covar,:);
    %model_covar.c = [0 ; 1 ; 0];
    model_covar.c = [0 ; 1 ];
    opt_glm.test = 'ttest';
    opt_glm.flag_beta = true;
    res_covar = niak_glm(model_covar,opt_glm);
    fprintf('%s\n',ly{list_cov(cc)});
    %res_covar.beta(model_covar.c>0,:)
    pce(cc,:) = res_covar.pce;
end
[fdr,test] = niak_fdr(pce(:),'BH',0.05);
pce
test = reshape(test,size(pce))

if 0

w_hat = model_covar.x*res_covar.beta;
plot(w_hat(:,1), model_covar.y(:,1),'.')

%% GLM analysis -- full brain
covar = tab2(:,9);
fd = tab2(:,15); 
mask_covar = ~isnan(covar)&(part~=2);
model_covar.x = [ones(sum(mask_covar),1) niak_normalize_tseries([covar(mask_covar) fd(mask_covar)],'mean')];
model_covar.y = tseries_ga(mask_covar,:);
model_covar.c = [0 ; 1 ; 0];
opt_glm.test = 'ttest';
opt_glm.flag_beta = true;
res_covar = niak_glm(model_covar,opt_glm);
res_covar.pce;
res_covar.beta(model_covar.c>0,:);
w_hat = model_covar.x*res_covar.beta;
plot(w_hat(:,2), model_covar.y(:,2),'.')

%% GLM analysis the other way
covar = tab2(:,13);
fd = tab2(:,15); 
mask_covar = ~isnan(covar);
model_covar.y = [niak_normalize_tseries(covar(mask_covar),'mean')];
model_covar.x = [ones(sum(mask_covar),1) niak_normalize_tseries(weights(mask_covar,:),'mean') fd(mask_covar)];
model_covar.c = [0 ; ones(size(weights,2),1) ; 0];
opt_glm.test = 'ftest';
opt_glm.flag_beta = true;
res_covar = niak_glm(model_covar,opt_glm);
res_covar.pce
%res_covar.beta(model_covar.c>0,:)

%% Visualize the cluster means
ind_visu = 1:max(part);
opt_vp.vol_limits = [0 1];
gd_avg = mean(stab,4);
for cc = ind_visu
    figure
    niak_montage(mean(stab(:,:,:,part==cc),4),opt_vp);
    title(sprintf('Average cluster %i',cc))
end
figure
niak_montage(gd_avg,opt_vp);
title('Grand average')

%% Visualize the cluster means, after substraction of the mean
opt_vp.vol_limits = [-0.2 0.2];
opt_vp.type_color = 'hot_cold';
ind_visu = 1:max(part);
gd_avg = mean(stab,4);
for cc = ind_visu
    figure
    niak_montage(mean(stab(:,:,:,part==cc),4)-gd_avg,opt_vp);
    title(sprintf('Average cluster %i',cc))
end

%% Write volumes
% The average per cluster
psom_mkdir(path_res)
avg_clust_raw = zeros(max(part),size(tseries,2));
for cc = 1:max(part)
    avg_clust_raw(cc,:) = mean(tseries(part==cc,:),1);
end
vol_avg_raw = niak_tseries2vol(avg_clust_raw,mask);
hdr.file_name = [path_res 'mean_clusters.nii.gz'];
niak_write_vol(hdr,vol_avg_raw);

% The demeaned, z-ified volumes
avg_clust = zeros(max(part),size(tseries,2));
for cc = 1:max(part)
    avg_clust(cc,:) = mean(tseries_ga(part==cc,:),1);
end
avg_clust = niak_normalize_tseries(avg_clust','median_mad')';
vol_avg = niak_tseries2vol(avg_clust,mask);
hdr.file_name = [path_res 'mean_cluster_demeaned.nii.gz'];
niak_write_vol(hdr,vol_avg);

hdr.file_name = [path_res 'grand_mean_clusters.nii.gz'];
niak_write_vol(hdr,mean(stab,4));

end