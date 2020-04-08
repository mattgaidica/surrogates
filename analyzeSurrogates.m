saveDir = '/Users/mattgaidica/Desktop/surrogates';

eventFieldnames = {'cueOn';'centerIn';'tone';'centerOut';'sideIn';'sideOut';'foodRetrieval'};
nSessions = 30;
nSurrogates = 20;
freqList = logFreqList([1 200],30);
Wlength = 400;
tWindow = 1;
shiftSec = 2;

zscoreSessions = zeros(nSessions,numel(eventFieldnames),Wlength,iFreq);
for iFreq = 1:numel(freqList)
    for iSession = 1:nSessions
        freqSurr = zeros(nSurrogates,Wlength);
        for iSurr = 0:nSurrogates
            if mod(iSurr,10) == 0
                fprintf('frequency %02d, session %02d, surrogate %05d\n',iFreq,iSession,iSurr);
            end
            surrFile = fullfile(saveDir,'scalograms',sprintf('%02d_%05d.mat',iSession,iSurr));
            matobj = matfile(surrFile);
            if iSurr == 0
                Wfreq = matobj.W(:,:,:,iFreq); % for later
            else
                thisPower = mean(matobj.W(:,:,iFreq),2);
                freqSurr(iSurr,:) = mean(matobj.W(:,:,iFreq),2);
            end
        end
        for iEvent = 1:numel(eventFieldnames)
            realData = mean(squeeze(Wfreq(iEvent,:,:)),2);
            zscoreSessions(iSession,iEvent,:,iFreq) = (realData - mean(freqSurr)') ./ std(freqSurr)';
        end
    end
end

ff(1200,300);
for iEvent = 1:7
    subplot(1,7,iEvent);
    imagesc(squeeze(mean(zscoreSessions(:,iEvent,:,:)))');
    set(gca,'YDir','normal')
    colormap(jet);
    caxis([-5 5]);
end
colorbar;