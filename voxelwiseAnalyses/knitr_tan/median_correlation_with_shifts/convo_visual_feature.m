% 10 October 2022 new run of Matt Bezdek's resampling, using new .csv inputs
%%%%%%%%%%%%%%%%%%%%%%%% Jo try #3: correct dt %%%%%%%%%%%%%%%%%%%%%%%%
% 0.033333 movie frame rate, 1.483 sec TR

inpath = '/data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/voxelwiseAnalyses/matlab_resampling2/';
outpath = '/data/nil-external/dcl/Events152_fMRI_NeuralMechanisms/voxelwiseAnalyses/matlab_resampling2/out_convo_visual/';

colids = {'rowid' 'time' 'frame_id' 'pixel_change_mean' 'pixel_change_var' 'luminance_mean' 'luminance_var'};
runids = {'1.2.3' '6.3.9' '3.1.3' '2.4.1'};  % movie names in run order

dt = 0.0333333;    % movie-stat sampling rate, in seconds    
TR = 1.483;   % in seconds

% movie durations in seconds, from https://wustl.app.box.com/file/836753376475  generate_event_files.py
durs = [586.103 679.429 585.936 645.796]; 
durs = round(durs / TR);    % movie durations, in TR

for rid = 1:4    % rid = 1; 
    infname = [inpath  runids{rid} '_C1_trim.csv'];  % input filename
    intbl = readmatrix(infname);
    for cid = 4:7   % rid = 1; cid = 2;
        Meas = durs(rid);   % how long to make the output timeseries; movie duration in TRs
        orig= intbl(:,cid);   % just one column
        orig = zscore(orig);
        hrf = spm_hrf(dt);     % https://github.com/neurodebian/spm12/blob/master/spm_hrf.m
        cTR = [0:Meas-1]*TR;
        ideal = conv(orig,hrf);
        ideal = ideal(1:end-length(hrf)+1);
        ideal = ideal/max(ideal)*1.1;
        idx = [0:length(orig)-1]*dt;
        convo = interp1(idx,ideal,cTR);
        convo = convo(~isnan(convo));
        
        writematrix(convo, [outpath  'conv_' runids{rid} '_', colids{cid}, '_dtFix.csv']);  
    end
end