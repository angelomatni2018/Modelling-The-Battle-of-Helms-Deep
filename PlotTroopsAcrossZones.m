function out = PlotTroopsAcrossZones(troopMatrix, armies, timeInterval)
    figure;
    for xx = 1:armies
        s(xx) = subplot(armies,1,xx);
        hold on;
        title(s(xx),['Troops for army ',num2str(xx),' for each time step']);
        ylabel(s(xx),'Number of troops');
        xlabel(s(xx),'Time step');
        totalTroopsX = sum(troopMatrix,2);
        % for each zone
        for ii = 1:size(troopMatrix,1)
            zone = totalTroopsX(ii,:,xx,:);
            if sum(zone) > 0
            plot(timeInterval,reshape(zone,1,size(zone,4)),...
                'DisplayName',['zone ',num2str(ii)]);
            end
        end

        legend(s(xx),'show')
    end
end