clear all 
close all 
clc 

%% IMPORTANT:
% Set the path to  the code %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Make sure you have set the right paths in this script
set_paths;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

methods = {"euclidean",...
           "ceml",...
           "nca", ...
           "egml",...
           "nonlinear_euclidean",...
           "nonlinear_ceml",...
           "nonlinear_nca", ...
           "nonlinear_egml"};

%% here we fix the partitions to compare all methods

% results_root_path = '/home/lgsanchez/work/Code/research/bci-eeg/metric-learning-premovement/results/cv_results/ceml';

feature_type = {"FTA_Features",...
                "FTA5_Features",...
                "RawEEG_Features"};

subject_id = {"B", "C1", "C2"};  


% sim_params.feature_type = feature_type{2};
% sim_params.pre_onset = true;
sim_params.n_folds = 10; % number of folds to get test error estimates
sim_params.n_runs = 1;
% sim_params.n_subfolds = 10; % number of folds to do model selection (this is a nested cv fold within each training-test fold)
% 
% % For this experiment, we are generating data windows of 850 milliseconds
% if sim_params.pre_onset
%     sim_params.wd_str_t = -0.85; % in seconds
%     sim_params.wd_end_t = 0;
% else %post-onset
%     sim_params.wd_str_t = 0;
%     sim_params.wd_end_t = 0.85;
% end

%% parameters of cross-validation

window_names = {"m085z000", "z000p085"};


% columns of table
METHOD1 = methods{1};
METHOD2 = methods{3};

FEATURE = feature_type{1};
SUBJECT = subject_id{1};
WINDOW = window_names{1};
RUN = 1;

test_data1 = loadTestResults(METHOD1, FEATURE, SUBJECT, WINDOW, RUN);
test_data2 = loadTestResults(METHOD2, FEATURE, SUBJECT, WINDOW, RUN);

[h, p_val, ci, stats] = ttest(test_data1.test_losses_fold, test_data2.test_losses_fold);
if h == 1
    if stats.tstat < 0 
        disp(sprintf('%s is statistically better than %s. pvalue = %d', METHOD1, METHOD2, p_val));
    else
        disp(sprintf('%s is statistically worse than %s. pvalue = %d', METHOD1, METHOD2, p_val));
    end
else
    disp(sprintf('%s and %s are not statistically different pvalue = %d', METHOD1, METHOD2, p_val))
end    


% compare method over same feature and same subject
testresults = zeros(length(methods)-1, length(methods)-1);
testpvalues = zeros(length(methods)-1, length(methods)-1);
teststat = cell(length(methods)-1, length(methods)-1);
for iMtd = 1 :length(methods)-1
    METHOD1 = methods{iMtd};
    test_data1 = loadTestResults(METHOD1, FEATURE, SUBJECT, WINDOW, RUN);
    for jMtd = (iMtd+1):length(methods)
        METHOD2 = methods{jMtd};
        test_data2 = loadTestResults(METHOD2, FEATURE, SUBJECT, WINDOW, RUN);
        [h, p_val, ci, stats] = ttest(test_data1.test_losses_fold, test_data2.test_losses_fold);
        testresults(iMtd, jMtd-1) = h;
        testpvalues(iMtd, jMtd-1) = p_val;
        if h == 1
            if stats.tstat < 0
                teststat{iMtd, jMtd-1} =  'better';
            else
                teststat{iMtd, jMtd-1} =  'worse';
            end
        else
            teststat{iMtd, jMtd-1} =  'not different';
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%% auxiliary functions
%%%%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function test_data = loadTestResults(METHOD, FEATURE, SUBJECT, WINDOW, RUN) 
results_root_path = fullfile('/home/lgsanchez/work/Code/research/bci-eeg/metric-learning-premovement/results/cv_results/', METHOD);
results_path = fullfile(results_root_path, FEATURE);
results_subject_path = fullfile(results_path, sprintf('Subject_%s',SUBJECT));
results_window_path = fullfile(results_subject_path, WINDOW);
results_run_path = fullfile(results_window_path, sprintf('run_%d', RUN));
test_data = load(fullfile(results_run_path, "all_val__test_losses.mat"));
end
