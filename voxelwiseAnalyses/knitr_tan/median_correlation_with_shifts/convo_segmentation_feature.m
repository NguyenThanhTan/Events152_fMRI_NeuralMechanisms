% 10 October 2022 new run of Matt Bezdek's resampling, using new .csv inputs
%%%%%%%%%%%%%%%%%%%%%%%% Jo try #3: correct dt %%%%%%%%%%%%%%%%%%%%%%%%
% 0.033333 movie frame rate, 1.483 sec TR

inpath = '/data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/voxelwiseAnalyses/knitr_tan/median_correlation_with_shifts/movie_segmentation_stats/';
outpath = '/data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/voxelwiseAnalyses/knitr_tan/median_correlation_with_shifts/out_convo_segmentation/';

% change pe or uncertainty here
colids = {'rowid' 'frame_id' 'time' 'first_second' 'uncertainty'};
% colids = {'rowid' 'frame_id' 'time' 'first_second' 'pe'};
runids = {'1.2.3' '6.3.9' '3.1.3' '2.4.1'};  % movie names in run order

dt = 1/3;    % movie-stat sampling rate, in seconds    
TR = 1.483;   % in seconds

% movie durations in seconds, from https://wustl.app.box.com/file/836753376475  generate_event_files.py
% durs = [586.103 679.429 585.936 645.796]; 
% durs = round(durs / TR);    % movie durations, in TR

for rid = 1:4    % rid = 1; 
    
    % change pe or uncertainty here
    infname = [inpath  runids{rid} '_kinect_trim_uncertainty.csv'];  % input filename
%     infname = [inpath  runids{rid} '_kinect_trim_pe.csv'];  % input filename
    intbl = readmatrix(infname);
    first_second = intbl(1, 3);
    last_second = intbl(size(intbl, 1), 3);
    dur = round((last_second - first_second) / TR);
    for cid = 5:5   % rid = 1; cid = 2;
        % Meas = durs(rid);   % how long to make the output timeseries; movie duration in TRs
        Meas = dur;   % how long to make the output timeseries; movie duration in TRs
        orig= intbl(:,cid);   % just one column
        orig = zscore(orig);
        hrf = spm_hrf(dt);     % https://github.com/neurodebian/spm12/blob/master/spm_hrf.m
        cTR = [0:Meas]*TR;
        ideal = conv(orig,hrf);
        ideal = ideal(1:end-length(hrf)+1);
        ideal = ideal/max(ideal)*1.1;
        idx = [0:length(orig)-1]*dt;
        convo = interp1(idx,ideal,cTR);
        convo = convo(~isnan(convo));

        writematrix(convo, [outpath  'conv_' runids{rid} '_', colids{cid}, '_dtFix.csv']);  
    end
end