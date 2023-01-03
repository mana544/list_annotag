function [] = focus_slannotation(slanno)
%FOCUS_SLANNOTATION 指定したSimulink注釈にフォーカスする
% モデル表示を、指定したSimulink注釈にフォーカスします。
% 有効なSimulink注釈の数値ハンドルもしくはSimulink.Annotationオブジェクトを指定してください。
% (モデルはあらかじめ開いておいてください)
% 
% focus_slannotation(slanno)
%
% [input]
% slanno    [Simulink注釈ハンドル(double) | Simulink.Annotationオブジェクト | Simulink注釈ハンドル(HEX format(char))]
%     フォーカスしたいSimulink注釈を、数値ハンドルもしくは
%     Simulink.Annotationオブジェクトで指定。
%     数値ハンドルはHEX値(倍精度浮動小数点形式の16文字のchar型)でも受け付けます。



if ischar(slanno)
    try
        % char型の場合は、数値変換した上でSimulink Annotationハンドルかどうかを検査
        % Simulink Annotationハンドルだったら引数の数値をそのまま利用
        slanno_num = hex2num(slanno);
        if strcmp(get_param(slanno_num, 'Type'), 'annotation')
            h = slanno_num;
        else
            error( ...
                'focus_slannotation:NotSLAnnotationHandle', ...
                '引数は有効なSimulink注釈ハンドルではありません。' ...
            )
        end
        
    catch ME
        baseException = MException( ...
            'focus_slannotation:InvalidArgument', ...
            '引数は有効なSimulink Annotationオブジェクト(ハンドル)ではありません。' ...
        );
        baseException = addCause(baseException, ME);
        throw(baseException)
    end
else
    % char型じゃなかったら、まずはsizeが[1 1]であることを確認する
    % (複数サイズは受け付けない)
    if isequal(size(slanno), [1 1])
        if isa(slanno, 'Simulink.Annotation')
            % Simulink.Annotation オブジェクトの場合はハンドルを逆引き
            h = slanno.Handle;

        elseif isa(slanno, 'double')
            try
                % double型の場合は、Simulink Annotationハンドルかどうかを検査
                % Simulink Annotationハンドルだったら引数の数値をそのまま利用
                if strcmp(get_param(slanno, 'Type'), 'annotation')
                    h = slanno;
                else
                    error( ...
                        'focus_slannotation:NotSLAnnotationHandle', ...
                        '引数は有効なSimulink注釈ハンドルではありません。' ...
                    )
                end
            catch ME
                baseException = MException( ...
                    'focus_slannotation:InvalidArgument', ...
                    '引数は有効なSimulink Annotationオブジェクト(ハンドル)ではありません。' ...
                );
                baseException = addCause(baseException, ME);
                throw(baseException)
            end
        else
            error( ...
                'focus_slannotation:NotSLAnnotationType', ...
                '引数はSimulink注釈ハンドルもしくはSimulink.Annotationオブジェクトではありません。' ...
            )
        end
    else
        error( ...
            'focus_slannotation:ArgumentSizeOver', ...
            '引数のsizeが[1 1]ではありません。引数には有効なSimulink Annotationオブジェクト(ハンドル)をひとつ指定してください。' ...
        )
    end
end


% hilite_systemでフォーカス(0.5秒間のみ色付け表示)
% スペック低いPC向け対策として'fixedSpacing'とする
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
% 1回目のみhilite_system実施
if get(tObj, 'TasksExecuted')==1
    hilite_system(h, 'find')
end

function edFcn(tObj, eObj, h)
% Timer Closing Callback Function
hilite_system(h, 'none')
delete(tObj)






