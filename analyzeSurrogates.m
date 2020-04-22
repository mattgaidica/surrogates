saveDir = '/Users/mattgaidica/Desktop/surrogates';

eventFieldnames = {'cueOn';'centerIn';'tone';'centerOut';'sideIn';'sideOut';'foodRetrieval'};
nSessions = 30;
nSurrogates = 1000;
freqList = logFreqList([1 200],30);
Wlength = 400;

zscoreSessions = zeros(nSessions,numel(eventFieldnames),Wlength,numel(freqList));
for iFreq = 1:numel(freqList)
    for iSession = 1:nSessions
        freqSurr = zeros(nSurrogates,Wlength);
        for iSurr = 0:nSurrogates
            if mod(iSurr,10) == 0
                fprintf('frequency %02d, session %02d, surrogate %05d\n',iFreq,iSession,iSurr);
            end
            surrFile = fullfile(saveDir,'scalograms_circ',sprintf('%02d_%05d.mat',iSession,iSurr));
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

subjects = {'R0088','R0117','R0142','R0154','R0182'};
subjectSessions = [1 4;5 11;12 24;25 29;30 30];

rows = 5;
cols = 7;
ff(1200,800);
for iSubject = 1:5
    for iEvent = 1:7
        subplot(rows,cols,prc(cols,[iSubject,iEvent]));
        curMat = squeeze(mean(zscoreSessions(...
            subjectSessions(iSubject,1):subjectSessions(iSubject,2),iEvent,:,:),1))';
        imagesc(curMat);
        set(gca,'YDir','normal');
        colormap(jet);
        caxis([-5 5]);
        if iEvent == 1
            title([subjects{iSubject},' n=',num2str(diff(subjectSessions(iSubject,:))+1),' sessions']);
        end
        if iEvent == 7
            cbAside(gca,'Z','k',[-5 5]);
        end
    end
end

rows = 2;
cols = 7;
ff(1200,600);
for iEvent = 1:7
    curMat = squeeze(mean(zscoreSessions(:,iEvent,:,:)))';
%     allMats = [];
%     for iSubject = 1:5
%         allMats(iSubject,:,:) = squeeze(mean(zscoreSessions(...
%             subjectSessions(iSubject,1):subjectSessions(iSubject,2),iEvent,:,:),1))';
%     end
    subplot(rows,cols,prc(cols,[1,iEvent]));
%     imagesc(squeeze(mean(allMats)));
    imagesc(curMat);
    set(gca,'YDir','normal');
    colormap(jet);
    caxis([-5 5]);
    if iEvent == 7
        cbAside(gca,'Z','k',[-5 5]);
    end
    
    subplot(rows,cols,prc(cols,[2,iEvent]));
%     pMat = 1 - normcdf(abs(squeeze(mean(allMats))))*size(freqList,1).^2;
    pMat = 1 - normcdf(abs(curMat))*size(freqList,1).^2;
    imagesc(pMat);
    set(gca,'YDir','normal');
    caxis([0 0.05]);
    if iEvent == 7
        cbAside(gca,'p','k',[0 0.05]);
    end
end

for iSession = 1:30
    ff(1200,300);
    for iEvent = 1:7
        subplot(1,7,iEvent);
        imagesc(squeeze(zscoreSessions(iSession,iEvent,:,:))');
        set(gca,'YDir','normal')
        colormap(jet);
        caxis([-5 5]);
    end
    colorbar;
    title(num2str(iSession));
end