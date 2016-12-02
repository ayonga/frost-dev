function [out] = display_system_info
%DISPLAY_SYSTEM_INFO Display info about system this is running on

% source:
% -   repo: https://github.com/apjanke/matlab-bench.git
%     sha: 6059d52
%     files:
%     -   path: bench_matlab_ops/display_system_info.m

% TODO: Detect when running in VM host

javaProps = java.lang.System.getProperties();
javaVersion = char(javaProps.get('java.version'));

hostname = char(java.net.InetAddress.getLocalHost().getHostName());
hostname = regexprep(hostname, '\..*', '');
osDescr = [char(javaProps.get('os.name')) ' ' char(javaProps.get('os.version'))];
systemExtra = '';

switch computer
    case {'MACI64'}
        cpuModel = sysctl_prop('machdep.cpu.brand_string');
        nCpuCores = str2double(sysctl_prop('machdep.cpu.core_count'));
        %cpuCacheSize = str2double(sysctl_prop('hw.l3cachesize')) / (2^20);
        memSize = sprintf('%.0f', str2double(sysctl_prop('hw.memsize')) / (2^30));
        cpuDescr = cpuModel;
    case {'PCWIN','PCWIN64'}
        cpuDescr = strrep(getenv('PROCESSOR_IDENTIFIER'), ', GenuineIntel', '');
        sysName = '';
        try
            cpuVendorId = winqueryreg('HKEY_LOCAL_MACHINE',...
                'HARDWARE\DESCRIPTION\System\CentralProcessor\0', 'ProcessorNameString');
            cpuDescr = cpuVendorId;
            sysName = winqueryreg('HKEY_LOCAL_MACHINE', 'HARDWARE\DESCRIPTION\System\BIOS',...
                'SystemProductName');
            systemExtra = sysName;
        catch
            % quash
        end
        w64Arch = getenv('PROCESSOR_ARCHITEW6432');
        if ~isempty(w64Arch)
            osDescr = [osDescr ' (WoW64)'];
        end
        memSize = memsize_using_memory_fcn();
    case {'GLNXA64'}
        %TODO: Linux support with procfs
        [~,cpuDescr] = system('grep "model name" /proc/cpuinfo | head -1');
        cpuDescr = chomp(regexprep(cpuDescr, '.*?: ', ''));
        [~,memSizeDescr] = system('grep "MemTotal" /proc/meminfo | head -1');
        [match,tok] = regexp(memSizeDescr, '(\d+) kB', 'match', 'tokens');
        if ~isempty(match)
            memK = str2double(tok{1}{1});
            memSize = sprintf('%.0f', memK / 2^10);
        else
            memSize = '???';
        end
        [~,kernelVer] = system('uname -v');
        systemExtra = chomp(kernelVer);
    otherwise
        % This shouldn't happen, but just in case...
        cpuDescr = '???';
        memSize = '???';
end


% Be terse
cpuDescr = strrep(cpuDescr, 'Intel(R) Core(TM) ', 'Core ');

miscStr = '';
if isdeployed
    miscStr = [miscStr ' DEPLOYED'];
end
%fprintf('Arch: %-8s  Release: %-s  %s\n', computer, ['R' version('-release')], miscStr);

if ~isempty(systemExtra)
    systemExtra = sprintf('(%s)', systemExtra);
end

% sprintf('Matlab %s on %s %s \n', ['R' version('-release')], computer, miscStr), ...
out = [ ...
    sprintf('Matlab %s / Java %s on %s %s (%s)\n', version, javaVersion,...
        computer, osDescr, hostname), ...
    sprintf('Machine: %s, %s GB RAM %s', cpuDescr, memSize, systemExtra) ...
    ];

if nargout == 0
    fprintf('%s\n', out);
end

end

function out = memsize_using_memory_fcn()
%MEMSIZE_USING_MEMORY_FCN Get memory size using memory()
%
% Only works on platforms that support memory(). OS X does not.
% Returns number of gigabytes as string.
[ma,mb] = memory();
out = sprintf('%.0f', mb.PhysicalMemory.Total / 2^30);
end

function out = chomp(str)
%CHOMP Remove trailing newline from string
out = regexprep(str, '\r?\n$', '');
end

function out = sysctl_prop(name)
%SYSCTL_PROP Get a sysctl property (OS X) by name as string
[status,str] = system(['sysctl -n ' name]);
if status ~= 0
    warning('Failed getting sysctl property %s: %s', name, str);
    out = '???';
else
    out = chomp(str);
end
end
