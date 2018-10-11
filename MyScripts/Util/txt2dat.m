function [] = txt2dat(folderpath)
%% Author: Petr Krýže
%% Email: petr.kryze@gmail.com
%%
% folderpath = 'C:\Users\Petr\Desktop\x\Data';
% textFiles = ls(fullfile(folderpath,'*.txt'));
textFiles = ls(fullfile(folderpath,'*raw.txt'));

for n = 1:size(textFiles,1)
    oldFile = strtrim(textFiles(n,:)); % strtrip - removes lead/trail whitespaces
    newFile = strcat(oldFile(1:end-4),'.dat'); % adds new file extension
    
    if (exist(fullfile(folderpath,newFile),'file')) % Existence check
        warning(strcat('File: ', newFile, ' already exists.'));
        continue
    end
    
    % Opens old file for reading
    fileIdRead = fopen(fullfile(folderpath, oldFile));
    
    % Opens new file for writing in text mode
    fileIdWrite = fopen(fullfile(folderpath, newFile),'wt');
    fprintf(fileIdWrite,'#BradykAn_Data_Set\n'); % Header
    
    textLine = fgetl(fileIdRead); % Reads line from file w/o newline char
    while ischar(textLine)
        tlinew = strrep(textLine, '  X: ', ';0;');
        tlinew = strrep(tlinew, ' Y: ', ';');
        tlinew = strrep(tlinew, ' Z: ', ';');
        
        fprintf(fileIdWrite,'%s;\n',tlinew);
        textLine = fgetl(fileIdRead);
    end
    
    fclose(fileIdRead);
    fclose(fileIdWrite);
end

end