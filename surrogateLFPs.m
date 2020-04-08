% setup
clear all % save your workspace if needed!
workDir = pwd;
saveDir = '/Users/mattgaidica/Desktop/surrogates'; % can change if saving to hard drive, but first: mkdir scalograms
cd(workDir); % just go there for dependencies

% load variables
% eventFieldnames = {'cueOn';'centerIn';'tone';'centerOut';'sideIn';'sideOut';'foodRetrieval'};
if ~exist('scaloTrials')
    load('scaloTrials')
end
rawdataList = dir(fullfile(workDir,'rawdata','session*.sev.mat'));
rawdataFiles = {rawdataList.name};

% params
nSessions = 30;
nSurrogates = 1000;
freqList = logFreqList([1 200],30);
Wlength = 400;
tWindow = 1;
shiftSec = 2;

for iSession = 1:nSessions
    for iSurr = 0:nSurrogates
        if isfile(fullfile(saveDir,'scalograms',sprintf('%02d_%05d.mat',iSession,iSurr)))
            continue;
        end
        if ~exist('sevFilt','var')
            load(fullfile(workDir,'rawdata',rawdataFiles{iSession})); % loads sevFilt, Fs, decimateFactor
            trials = scaloTrials{iSession};
            [trialIds,allTimes] = sortTrialsBy(trials,'RT'); % also filters successful
            trials = curateTrials(trials(trialIds),sevFilt,Fs,[]); % removes artifact trials
            fprintf('loading session %02d: %s\n',iSession,rawdataFiles{iSession});
        end
        fprintf('processing session %02d, surrogate %05d',iSession,iSurr);
        if iSurr == 0 % real data, no shift
            [trials_surr,rShift] = shiftTimestamps(trials,0);
        else % shifted data
            [trials_surr,rShift] = shiftTimestamps(trials,shiftSec);
        end
        % only process centerIn, save time
        tic;
        [W,all_data] = eventsLFPv2(trials_surr,sevFilt,tWindow,Fs,freqList,{'centerIn'});
        % resize peri-event data, squeeze single event, toss out complex
        W = abs(squeeze(W(:,round(linspace(size(W,1),size(W,2),Wlength)),:,:))).^2;
        fprintf(' %1.2fs\n',toc);
        save(fullfile(saveDir,'scalograms',sprintf('%02d_%05d',iSession,iSurr)),'W','rShift','-v7.3');
    end
    clear sevFilt; % done with session
end