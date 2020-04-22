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
    for iSurr = 1:nSurrogates
        if isfile(fullfile(saveDir,'scalograms_circ',sprintf('%02d_%05d.mat',iSession,iSurr))) % CIRC
            continue;
        end
        if ~exist('sevFilt','var')
            load(fullfile(workDir,'rawdata',rawdataFiles{iSession})); % loads sevFilt, Fs, decimateFactor
            trials = scaloTrials{iSession};
            [trialIds,allTimes] = sortTrialsBy(trials,'RT'); % also filters successful
            fprintf('loading session %02d: %s\n',iSession,rawdataFiles{iSession});
        end
        fprintf('processing session %02d, surrogate %05d',iSession,iSurr);
        if iSurr == 0 % real data, no shift
            [trials,rShift] = shiftTimestamps(trials(trialIds),0);
            trials_surr = curateTrials(trials,sevFilt,Fs,[]); % removes artifact trials
        else % shifted data
            if true % CIRC, shift SEV instead of all trial numbers
                shiftSamples = round((rand * numel(sevFilt)) + 1);
                sevFilt = circshift(sevFilt,shiftSamples);
                % pass in only correct trials WITH shifted SEV to curate
                % note, this may mean # of trials in real scalograms do not
                % match the surrogate because of exclusion
                trials_surr = curateTrials(trials(trialIds),sevFilt,Fs,[]);
                rShift = shiftSamples * Fs;
            else
                [trials,rShift] = shiftTimestamps(trials(trialIds),shiftSec);
                trials_surr = curateTrials(trials(trialIds),sevFilt,Fs,[]); % removes artifact trials
            end
        end
        % only process centerIn, save time
        tic;
        [W,all_data] = eventsLFPv2(trials_surr,sevFilt,tWindow,Fs,freqList,{'centerIn'});
        % resize peri-event data, squeeze single event, toss out complex
        W = abs(squeeze(W(:,round(linspace(size(W,1),size(W,2),Wlength)),:,:))).^2;
        fprintf(' %1.2fs\n',toc);
        save(fullfile(saveDir,'scalograms_circ',sprintf('%02d_%05d',iSession,iSurr)),'W','rShift','-v7.3'); % CIRC
    end
    clear sevFilt; % done with session
end