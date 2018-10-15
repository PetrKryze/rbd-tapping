% Script for data renaming and changing from txt to dat files
%% Author: Petr Krýže
%% Email: petr.kryze@gmail.com
%%
clear
clc
close all

root = 'C:\Users\Petr\Disk Google\Thesis\Matlab\Data\Complete datasets\Dodatecna Data Srpen 2018';
contents = ls(root);
subfolder = 'Edited';

if isempty(contents)
    warning('Folder is empty.');
    return; 
end

for n = 1:size(contents,1)
    folname = strtrim(contents(n,:));
    folpath = fullfile(root,folname);
    
    if isdir(fullfile(root,folname)) && isFolderNameOk(folname)
        txt2dat(folpath); % Transfers text data to DAT files
        
        if ~exist(fullfile(folpath,subfolder), 'dir')
            mkdir(folpath,subfolder);
        end
        
        datFiles = ls(fullfile(folpath,'*.dat'));
        for m = 1:size(datFiles,1)
            file = strtrim(datFiles(m,:));
            
            splitChar = '_';
            s = split(file,splitChar);
            name = strcat(folname,splitChar,s{2});
            
            i = 1;
            while(1)
                completeName = strcat(name,splitChar,num2str(i),'.dat');
                
                newfile = fullfile(folpath,subfolder,completeName);
                if ~exist(newfile,'file')
                    movefile(fullfile(folpath,file),newfile);
                    break;
                end
                i = i + 1;
            end
            
        end
    else
        warning('%s is a file.',folname);
    end
end


function b = isFolderNameOk(folname)
    b = false;
    labels = ["BIO-PD", "CON", "RBD"];
    
    for i = 1:length(labels)
        if startsWith(folname,labels(i))
           b = true;
           return;
        end
    end
end