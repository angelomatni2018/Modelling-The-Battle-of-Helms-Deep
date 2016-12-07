function out = PlotTotalTroopsAcrossTime(troopMatrix, armies, timeInterval, soldierNames)
    figure;
    for xx = 1:armies
        s = subplot(armies,1,xx);
        hold on;
        title(s,{['Total troops for army ',num2str(xx),' for each time step']});
        ylabel(s,'Number of troops');
        xlabel(s,'Time step');    
        totalTroops = sum(troopMatrix,1);
        % for each soldier type
        for ii = 1:size(troopMatrix,2)
            soldier = totalTroops(:,ii,xx,:);
            if sum(soldier) > 0
            plot(timeInterval,reshape(soldier,1,size(soldier,4)), ...
                'DisplayName',soldierNames{ii});
            end
        end

        legend(s,'show')
    end
    
end