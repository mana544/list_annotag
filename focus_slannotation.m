function [] = focus_slannotation(slanno)
%FOCUS_SLANNOTATION �w�肵��Simulink���߂Ƀt�H�[�J�X����
% ���f���\�����A�w�肵��Simulink���߂Ƀt�H�[�J�X���܂��B
% �L����Simulink���߂̐��l�n���h����������Simulink.Annotation�I�u�W�F�N�g���w�肵�Ă��������B
% (���f���͂��炩���ߊJ���Ă����Ă�������)
% 
% focus_slannotation(slanno)
%
% [input]
% slanno    [Simulink���߃n���h��(double) | Simulink.Annotation�I�u�W�F�N�g | Simulink���߃n���h��(HEX format(char))]
%     �t�H�[�J�X������Simulink���߂��A���l�n���h����������
%     Simulink.Annotation�I�u�W�F�N�g�Ŏw��B
%     ���l�n���h����HEX�l(�{���x���������_�`����16������char�^)�ł��󂯕t���܂��B



if ischar(slanno)
    try
        % char�^�̏ꍇ�́A���l�ϊ��������Simulink Annotation�n���h�����ǂ���������
        % Simulink Annotation�n���h��������������̐��l�����̂܂ܗ��p
        slanno_num = hex2num(slanno);
        if strcmp(get_param(slanno_num, 'Type'), 'annotation')
            h = slanno_num;
        else
            error( ...
                'focus_slannotation:NotSLAnnotationHandle', ...
                '�����͗L����Simulink���߃n���h���ł͂���܂���B' ...
            )
        end
        
    catch ME
        baseException = MException( ...
            'focus_slannotation:InvalidArgument', ...
            '�����͗L����Simulink Annotation�I�u�W�F�N�g(�n���h��)�ł͂���܂���B' ...
        );
        baseException = addCause(baseException, ME);
        throw(baseException)
    end
else
    % char�^����Ȃ�������A�܂���size��[1 1]�ł��邱�Ƃ��m�F����
    % (�����T�C�Y�͎󂯕t���Ȃ�)
    if isequal(size(slanno), [1 1])
        if isa(slanno, 'Simulink.Annotation')
            % Simulink.Annotation �I�u�W�F�N�g�̏ꍇ�̓n���h�����t����
            h = slanno.Handle;

        elseif isa(slanno, 'double')
            try
                % double�^�̏ꍇ�́ASimulink Annotation�n���h�����ǂ���������
                % Simulink Annotation�n���h��������������̐��l�����̂܂ܗ��p
                if strcmp(get_param(slanno, 'Type'), 'annotation')
                    h = slanno;
                else
                    error( ...
                        'focus_slannotation:NotSLAnnotationHandle', ...
                        '�����͗L����Simulink���߃n���h���ł͂���܂���B' ...
                    )
                end
            catch ME
                baseException = MException( ...
                    'focus_slannotation:InvalidArgument', ...
                    '�����͗L����Simulink Annotation�I�u�W�F�N�g(�n���h��)�ł͂���܂���B' ...
                );
                baseException = addCause(baseException, ME);
                throw(baseException)
            end
        else
            error( ...
                'focus_slannotation:NotSLAnnotationType', ...
                '������Simulink���߃n���h����������Simulink.Annotation�I�u�W�F�N�g�ł͂���܂���B' ...
            )
        end
    else
        error( ...
            'focus_slannotation:ArgumentSizeOver', ...
            '������size��[1 1]�ł͂���܂���B�����ɂ͗L����Simulink Annotation�I�u�W�F�N�g(�n���h��)���ЂƂw�肵�Ă��������B' ...
        )
    end
end


% hilite_system�Ńt�H�[�J�X(0.5�b�Ԃ̂ݐF�t���\��)
% �X�y�b�N�ႢPC�����΍�Ƃ���'fixedSpacing'�Ƃ���
t = timer( ...
    'BusyMode', 'queue', ...
    'ExecutionMode', 'fixedSpacing', ...
    'Period', 0.5, ...
    'TasksToExecute', 2, ...
    'StartDelay' , 0.0, ...
    'TimerFcn', {@tmFcn, h}, ...
    'StopFcn', {@edFcn, h} ...
);
start(t);


function tmFcn(tObj, eObj, h)
% Timer Callback Function
% 1��ڂ̂�hilite_system���{
if get(tObj, 'TasksExecuted')==1
    hilite_system(h, 'find')
end

function edFcn(tObj, eObj, h)
% Timer Closing Callback Function
hilite_system(h, 'none')
delete(tObj)






