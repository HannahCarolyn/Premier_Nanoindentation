function [Tipradiusfitting,final_main_popin_data_struct]=hertzian2(base_file_directory, mapping_type,final_main_popin_data_struct,naughty_indents_list,red_indents_list,numberofexpectedpopin)

noofindents=length([final_main_popin_data_struct.Indent_Index]);
nbytes = fprintf('Processing indent 0.'); % Initialising changing number display
 fig1=figure;

PopinP=[final_main_popin_data_struct.PopinData].';
PopinshapingP=reshape(PopinP,[numberofexpectedpopin noofindents]); 
PopinfinalP=PopinshapingP';

Popinh=[final_main_popin_data_struct.PopinDatah].';
Popinshapingh=reshape(Popinh,[numberofexpectedpopin noofindents]); 
Popinfinalh=Popinshapingh';


for i=0:noofindents-1 % loop for each of the indents with zero corrections
       fprintf(repmat('\b',1,nbytes)) % Changing number display
    nbytes = fprintf('Processing indent %d.', i); % Changing number display
    j=i+1; % correcting zero problem when putting data into the arrays
    completion_fraction = i/(noofindents-1); % Calculates fraction for progress bar
        waitbar(completion_fraction); % Updates progress bar
    if ismember(final_main_popin_data_struct(j).Indent_Index,naughty_indents_list) % Note naughty list always contains red error indents, but only contains amber indents if user says so using exclude_dodgy
      % Do nothing
    else
    
        Pbefore1popin=[];
     hbefore1popin=[];
     hbefore1popin3over2=[];
     
    if mapping_type == "automated_indentation_grid_array"
            indentsnostring= sprintf('indent_%04d',i); %string of the field name
            loading_P_h_data=final_main_popin_data_struct(j).Displacement_Load_Data;
    
            h=loading_P_h_data(:,1);
            P=loading_P_h_data(:,2);
            
            numberofpoints=numel(h);
    
   
    
       % loading section of curve
    
    
        tolerance=0.01; %need to move this out
        index = find( abs(gradient(P)) < tolerance );
        noofdatappoint=numel(P);
        limit=round(noofdatappoint*0.95); %unhard code this
        indexcatch= find(index < limit);
        index =index(indexcatch);
        Pmaxindex=max(index);
        saving_Pmaxindex(j,1)=Pmaxindex;
            loadingP=P(1:Pmaxindex); %extracting the loading section of load
        loadingh=h(1:Pmaxindex); % extracting the loading section of load


  
      else if mapping_type == "xpm_indentation_map"
                  indentsnostring= sprintf('indent_%04d',i); %string of the field name
            loading_P_h_data=updated_main_data_struct(j).Loading_Segment;
    
            loadingh=loading_P_h_data(:,1);
            loadingP=loading_P_h_data(:,2);
      end
    end

         if PopinfinalP(j,1)>500 % unhardcode this
             PopinfinalPfilter(j,1)=NaN;
         else 
             PopinfinalPfilter(j,1)=PopinfinalP(j,1);
         end

          firstpopinload=PopinfinalPfilter(j,1);

          if (isnan(firstpopinload))
              Tipradiusfitting(j,1)=NaN;
              final_main_popin_data_struct(j).ShearStress=NaN;
          else
          Er=(final_main_popin_data_struct(j).Reduced_Modulus)*10^9;
           indexofpostive=find(loadingh>0);
           loadingPabovezero=loadingP(indexofpostive);
           loadinghabovezero=loadingh(indexofpostive);

    indexoffirstpopin=find(loadingPabovezero==firstpopinload);

    zerocorrect=final_main_popin_data_struct(j).hzeroerror;
  

%     Pbefore1popin=(loadingPabovezero(1:indexoffirstpopin))*10^-6;
%     hbefore1popin=(loadinghabovezero(1:indexoffirstpopin)-zerocorrect)*10^-9;

    Pbefore1popin=(loadingPabovezero(1:indexoffirstpopin));
    hbefore1popin=(loadinghabovezero(1:indexoffirstpopin)-zerocorrect);
    
    hbefore1popin3over2=(hbefore1popin).^(3/2);

    numberofdatapoints=numel(Pbefore1popin);
    lowerlimitindex=round(numberofdatapoints*0.2);
    

 [xData, yData] = prepareCurveData( hbefore1popin3over2(lowerlimitindex:numberofdatapoints), Pbefore1popin(lowerlimitindex:numberofdatapoints));
 try

% Set up fittype and options.
ft = fittype( 'poly1' );

% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, 'Normalize', 'off' );


% [linearfitcoeffcient,S,mu]=polyfit(hbefore1popin3over2,Pbefore1popin,1);
 
%     gradoffit=linearfitcoeffcient(1);

coefficients=coeffvalues(fitresult);
gradoffit=coefficients(1);
gradoffitscaled=gradoffit*10^7.5;
    R=((0.75*gradoffitscaled)/Er)^2;
    Tipradiusfitting(j,1)=R*10^9;

    % Plot fit with data.
figure( fig1 );
h = plot( fitresult, xData, yData );
legend( h, 'Pbefore1popin vs. hbefore1popin3over2', 'untitled fit 1', 'Location', 'NorthEast', 'Interpreter', 'none' );
% Label axes
  xlabel("h^(3/2) (nm)")
    ylabel("load (uN)")
    title("Hertizan Fit")
grid on
hold on
 catch
     Tipradiusfitting(j,1)=NaN;
 end



    firstpopinloadscaled=firstpopinload*10^-6;
    cals1=6*Er^2;
    cals2=((pi)^3)*(R^2);
    cals3=(cals1/cals2)^(1/3);
    stress=0.31*cals3*(firstpopinloadscaled^(1/3));
    stresssaving(j)=stress*10^-9;
    stresssaving=stresssaving';

    final_main_popin_data_struct(j).ShearStress=stresssaving(j);



          end

    end
end


    %% finding shear stress




% Raverage=mean(Tipradiusfitting,"omitnan");
% Rstd=std(Tipradiusfitting,"omitnan");
% Rsize=nnz(~isnan(Tipradiusfitting));
% Rstderror=Rstd/sqrt(Rsize);
% 
% 
% for i2=0:noofindents-1
%     j2=i2+1;
%     Erperindent=(final_main_popin_data_struct(j2).Reduced_Modulus)*10^9;
%     Raveragedscaled=Raverage*10^-9;
%     firstpopinloadscaled=PopinfinalPfilter(j2,1)*10^-6;
%     cals1=6*Erperindent^2;
%     cals2=((pi)^3)*(Raveragedscaled^2);
%     cals3=(cals1/cals2)^(1/3);
%     stress=0.31*cals3*(firstpopinloadscaled^(1/3));
%     stresssaving(j2)=stress*10^-9;
%     stresssaving=stresssaving';
% 
%     final_main_popin_data_struct(j2).ShearStress=stresssaving(j2);
% end
end


