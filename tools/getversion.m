function [major_version, minor_version] = getversion()
%GETVERSION Gets MATLAB version (e.g. R2015B)

[~,version_string] = regexp(version, '\((.*?)\)', 'match', 'tokens'); % 'R2011b'
[~,tok] = regexp(version_string{1},'R([0-9]*)(a|b)', 'match', 'tokens'); % ['2011', 'b']
major_version = str2double(tok{1}{1}{1});
minor_version = tok{1}{1}{2};

end

