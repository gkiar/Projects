%% Make the figures, please
clear;
search_path = '/home/sebastian/Projects/niak_multiscale/remote_run/cons/';
data_pattern = 'simu_var_\w*.mat';
out_path = '/home/sebastian/Projects/niak_multiscale/remote_run/cons/figures';

param_prec = 2;
ref_t = 100;
ref_n = 16;
ref_s = [4 16];

% Prepare the reference data
opt_s.type = 'checkerboard';
opt_s.t = ref_t;
opt_s.n = ref_n*ref_n;
opt_s.nb_clusters = ref_s;
tseries_ref = niak_simus_scenario(opt_s);
R_ref = niak_build_correlation(tseries_ref);
hier_ref = niak_hierarchical_clustering(R_ref);
order_ref = niak_hier2order(hier_ref);

% select among:
%   - correlation
%   - partition
%   - stab_inter
%   - stab_inter
%   - sil
%   - stab_core: stability of a given zone (supply the number of the zone with
%   show_zone
show_me = 'stab_core'
show_zone = 1;

if ~isdir(out_path)
    niak_mkdir(out_path);
    warning('Created out dir at %s\n', out_path);
end

search_dir = dir(search_path)';

store.param = [];
item_count = 0;

% Loop through the directories and find the ones that contain files
for item = search_dir
    if item.isdir
        % This is a directory
        fprintf('Found directory %s\n', item.name);
        cur_path = fullfile(search_path, item.name);
        % Get the fwhm and variance from the dir name
        fwhm_match_i = regexp(item.name, '(?<=fwhm_)\d*', 'match');
        fwhm_match_d = regexp(item.name, '(?<=fwhm_\d*_)\d*', 'match');
        var_match_i = regexp(item.name, '(?<=var_)\d*', 'match');
        var_match_d = regexp(item.name, '(?<=var_\d*_)\d*', 'match');
        if ~isempty(fwhm_match_i) && ~isempty(var_match_i) && ~isempty(fwhm_match_d) && ~isempty(var_match_d)
            item_count = item_count + 1;
            fwhm_i = str2double(fwhm_match_i{1});
            var_i = str2double(var_match_i{1});
            fwhm_d = str2double(fwhm_match_d{1}) / 10^param_prec;
            var_d = str2double(var_match_d{1}) / 10^param_prec;
            fwhm = fwhm_i + fwhm_d;
            var = var_i + var_d;
        else
            % The dir name does not contain fwhm and var
            warning('%s does not contain fwhm or var in its name. Skipping\n', cur_path);
            continue
        end
        
        % See if the sought after file is present
        files = dir(cur_path)';
        for file = files
            switch show_me
                case 'correlation'
                    % We are looking for the data file with a pattern
                    match = regexp(file.name, data_pattern, 'match');
                    if ~isempty(match)
                        s_file = file.name;
                    else
                        continue
                    end
                case 'partition'
                    s_file = 'stab_core.mat';
                case 'stab_intra'
                    s_file = 'surf_silhouette.mat';
                case 'stab_inter'
                    s_file = 'surf_silhouette.mat';
                case 'sil'
                    s_file = 'surf_silhouette.mat';
                case 'stab_core'
                    % We are looking for the data file with a pattern
                    match = regexp(file.name, data_pattern, 'match');
                    if ~isempty(match)
                        s_file = file.name;
                    else
                        continue
                    end
                otherwise
                    error('Don''t know what to do with the selected show option.\n');
            end
            
            % See if the current file matches the pattern
            if strcmp(file.name, s_file)
                % We have a match
                data = load([cur_path filesep file.name]);
                fprintf('Found a match for %s in %s:\n    %s\n', show_me, item.name, file.name);
                break
            end
        end
     
        % Start preparing the data storage
        store.param(1,item_count) = fwhm;
        store.param(2,item_count) = var;
        
        % If we run on a file basis, do this:
        if strcmp(show_me, 'correlation')
            sc_name = 'correlation';
            if ~isfield(store, 'correlation')
                store.correlation = {};
            end
            R = niak_build_correlation(data.data);
            show = R(order_ref, order_ref);
            store.(sc_name){item_count} = show;
            
        elseif strcmp(show_me, 'stab_core')
            p_file = [cur_path filesep 'stab_core.mat'];
            if exist(p_file, 'file') ~= 2
                error('Could not find part file in %s. Needed fore %s\n', cur_dir, show_me);
            end
            tmp_part = load(p_file);
            scales = tmp_part.scale(:);
            num_scale = length(scales);
            
            for sc_id = 1:num_scale
                sc_name = sprintf('sc%d',scales(sc_id));
                if ~isfield(store, sc_name)
                    store.(sc_name) = {};
                end
                
                part = tmp_part.part(:,sc_id);
                mask = reshape(part==show_zone, [ref_n ref_n]);

                tseries = data.data;
                t_4d = reshape(tseries', [ref_n ref_n 1 ref_t]);
                show = niak_build_rmap(t_4d, mask);
                store.(sc_name){end+1} = show;
            end
            
        else
            % Loop through the scales and store them in the structure
            scales = data.scale(:);
            num_scale = length(scales);

            for sc_id = 1:num_scale
                sc_name = sprintf('sc%d',scales(sc_id));
                if ~isfield(store, sc_name)
                    store.(sc_name) = {};
                end
                
                switch show_me
                    case 'partition'
                        part = data.part(:,sc_id);
                        show = reshape(part, [ref_n ref_n]);
                        
                    case 'stab_intra'
                        scale_name = data.scale_names{sc_id};
                        intra = data.stab_surf.(scale_name).intra;
                        show = reshape(intra, [ref_n ref_n]);
                        
                    case 'stab_inter'
                        scale_name = data.scale_names{sc_id};
                        inter = data.stab_surf.(scale_name).inter;
                        show = reshape(inter, [ref_n ref_n]);

                    case 'sil'
                        scale_name = data.scale_names{sc_id};
                        sil = data.sil_surf.(scale_name);
                        show = reshape(sil, [ref_n ref_n]);

                    otherwise
                        error('Don''t know what to do with the selected show option.\n');
                end
                store.(sc_name){end+1} = show;
            end
        end
    end
end

% Sort the files according to fwhm and var
num_files = size(store.param, 2);
if num_files ~= item_count
    error('%d ~= %d', num_files, item_count);
end
index = 1:num_files;
params = store.param;
num_fwhm = length(unique(store.param(1,:)));
num_var = length(unique(store.param(2,:)));
[fwhm_sorted, fwhm_index] = sort(params(1,:));
fwhm_values = unique(fwhm_sorted);
tmp(1,:) = fwhm_sorted;
tmp(2,:) = params(2,fwhm_index);
index = index(fwhm_index);
for fwhm_id = 1:length(fwhm_values)
    fwhm_val = fwhm_values(fwhm_id);
    mask = find(tmp(1,:)==fwhm_val);
    [sorted, ind] = sort(tmp(2,mask));
    tmp_b = index(mask);
    index(mask) = tmp_b(ind);
end

% Preprocess the storage
fields = fieldnames(store);
use_fields = {};
for field_id = 1:length(fields)
    field = fields{field_id};
    if ~strcmp(field, 'param')
        % it's something else
        if length(store.(field)) == item_count
            % We have all the values we are looking for
            fprintf('I found all %d items in %s.\n', item_count, field);
            use_fields{end+1} = field;
        else
            fprintf('I found only %d of the needed %d items in %s.\n', length(store.(field)), item_count, field);
            store = rmfield(store, field);
        end
    end
end

% Loop through the stored data
opt.flag_bar = false;
for name_id = 1:length(use_fields)
    field_name = use_fields{name_id};
    % Open up the figure
    fig = figure('visible','off');
    run_count = 1;
    for par_id = 1:num_files
        par_ind = index(par_id);
        fwhm = store.param(1,par_ind);
        var = store.param(2,par_ind);
        % Grab the correct data
        show = store.(field_name){par_ind};
        % Open the subplot
        subaxis(num_fwhm, num_var, par_id,'Spacing', 0.01, 'Padding', 0, 'Margin', 0.01);

        % Plot the data
        niak_visu_matrix(show, opt);
        title(sprintf('%s', name_id));
        axis off

    end

    % Name of the file to save
    img_name = sprintf('%s_%s.png', field_name, show_me);
    img_path = [out_path filesep img_name];
    print(fig, img_path, '-dpng');
    close(fig);

end
        


        