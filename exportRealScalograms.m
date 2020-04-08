saveDir = '/Users/mattgaidica/Desktop/surrogates';
nSessions = 30;
eventFieldnames = {'cueOn';'centerIn';'tone';'centerOut';'sideIn';'sideOut';'foodRetrieval'};

for iSession = 1:nSessions
    load(fullfile(workDir,'rawdata',rawdataFiles{iSession})); % loads sevFilt, Fs, decimateFactor
    trials = scaloTrials{iSession};
    [trialIds,allTimes] = sortTrialsBy(trials,'RT'); % also filters successful
    trials = curateTrials(trials(trialIds),sevFilt,Fs,[]); % removes artifact trials
    fprintf('loading session %02d: %s\n',iSession,rawdataFiles{iSession});
    
    % only process centerIn, save time
    tic;
    [W,all_data] = eventsLFPv2(trials,sevFilt,tWindow,Fs,freqList,eventFieldnames);
    % resize peri-event data, squeeze single event, toss out complex
    W = abs(squeeze(W(:,round(linspace(size(W,1),size(W,2),Wlength)),:,:))).^2;
    save(fullfile(saveDir,'scalograms',sprintf('%02d_00000',iSession)),'W','-v7.3');
end