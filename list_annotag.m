function [varargout] = list_annotag(mdl, tag)
%LIST_ANNOTAG アノテーションタグ付きコメントの一覧表示
% Simulinkモデル内の注釈で、'TODO: ...' から始まる“アノテーションタグ付きコメント”を検索し、
% MATLABコマンドウインドウに一覧表示します。
% 
% list_annotag()
% list_annotag(mdl)
% list_annotag(mdl, tag)
% list_annotag([], tag)
% 
% find_result = list_annotag(____)
% 
% [input]
% mdl    [char]
%     検索対象のシステムを指定します。
%     省略した場合は、現在アクティブなモデル 'bdroot' を検索対象にします。
% tag    [char | 1xN cell(char)]
%     検索対象のタグを指定します。
%     例: 'FIXME'
%         {'FIXME', 'MEMO'}
%     省略した場合は、以下のデフォルトのタグを検索します。
%       * 'TODO'
%       * 'FIXME'
%       * 'XXX'
%       * 'REVIEW'
%       * 'OPTIMIZE'
%       * 'CHANGED'
%       * 'NOTE'
%       * 'WARNING'
% 
% [output]
% find_result    [1xN struct]
% │   tagごとにグルーピングした検索結果を格納
% │   Nはtagで指定した検索タグの数。
% ├── Tag    [Char]
% │       タグ名。
% └── Object    [1xM cell(Simulink.Annotationオブジェクト)]
%         検索でヒットした注釈オブジェクト
% 

% デフォルト検索タグの定義
defaulttag = {'TODO', 'FIXME', 'XXX', 'REVIEW', 'OPTIMIZE', 'CHANGED', 'NOTE', 'WARNING'};

% 引数の数のチェック
switch nargin
    case 0
        mdl = bdroot;
        tag = defaulttag;
    case 1
        % 引数 mdl が空指定の場合は、bdrootを格納
        if isempty(mdl)
            mdl = bdroot;
        end
        tag = defaulttag;
    case 2
        % 引数 mdl が空指定の場合は、bdrootを格納
        if isempty(mdl)
            mdl = bdroot;
        end
        % 引数 tag が文字列の場合は 1x1 cellに格納し直し
        if ischar(tag)
            tag = {tag};
        end
    otherwise
        error('list_annotag:arg_check_failed', '引数の数がおかしいよ！');
end

% アノテーションタグ付きコメントの検索
finded_result = find_annotag(mdl, tag);
% アノテーションタグ付きコメントを一覧表示
show_annotag(finded_result);

% 返り値の格納
% 呼び出し側で出力引数が指定されている場合は、finded_result構造体を投げ返す
if nargout == 1
    varargout{1} = finded_result;
end


function [fr] = find_annotag(mdl, tag)
%FIND_ANNOTAG アノテーションタグ付きコメントを検索
% Simulinkモデル内の注釈で、'TODO: ...' から始まる“アノテーションタグ付きコメント”を検索します。
%
% fr = find_annotag(mdl, tag)
%
% [input]
% mdl    [char]
%     検索対象のシステムを指定します。
% tag    [1xN cell(char)]
%     検索対象のタグを指定します。
%     例: {'FIXME', 'MEMO'}
%
% [output]
% fr    [1xN Struct]
% │   検索結果格納構造体
% ├── Tag    [Char]
% │       タグ名。
% └── Object    [1xM cell(Simulink.Annotationオブジェクト)]
%         検索でヒットした注釈オブジェクト

% すべての注釈のハンドルを取得
h = find_system(mdl, 'FindAll', 'on', 'Variants', 'AllVariants', 'type', 'annotation');
% ハンドルから、Simulink.Annotation オブジェクトの取得
anno_obj = get_param(h, 'Object');
% 注釈が2つ以上の場合はセル配列に格納された
% Simulink.Annotation オブジェクトが返ってくるけど、
% 注釈が1つの場合はSimulink.Annotation オブジェクトが
% 返ってくるため、1x1セル配列に変換する
if ~iscell(anno_obj)
    anno_obj = {anno_obj};
end
% 注釈テキスト
text = cellfun(@fetch_text, anno_obj, 'UniformOutput',false);

% 検索結果格納構造体
fr = struct( ...
    'Tag', tag, ...
    'Object', [] ...
);

% 検索
for i = 1:length(fr)
    % タグ文字列 'TAG: '
    tag_str = sprintf('%s: ', fr(i).Tag);
    % タグ文字列 'TAG: 'の文字数
    tag_str_len = length(tag_str);
    % テキストからアノテーションタグを検索
    idx = cellfun(@(x) strncmp(x, tag_str, tag_str_len), text);
    % 注釈オブジェクトとテキストを抽出
    fr(i).Object = anno_obj(idx);
end


function txt = fetch_text(obj)
%FETCH_TEXT Simulink.Annotationオブジェクトから注釈テキストを取得する
% PlainTextプロパティが存在する場合はPlainTextから取得。
% PlainTextプロパティが存在しない場合(古いVerには存在しない)はTextから取得。
% 
% [input]
% obj    [Simulink.Annotation オブジェクト]
%     Simulink.Annotationオブジェクト
% 
% [output]
% txt    [char]
%     注釈テキスト

if isprop(obj, 'PlainText')
    txt = obj.PlainText;
else
    txt = obj.Text;
end


function show_annotag(fr)
%SHOW_ANNOTAG アノテーションタグ付きコメントの一覧表示
% Simulinkモデル内の注釈で、'TODO: ...' などから始まる“アノテーションタグ付きコメント”を
% MATLABコマンドウインドウ上に一覧表示します。
% 
% show_annotag(fr)
% 
% [input]
% fr    [1xN struct]
%     検索結果構造体

% タグごとにループ
for i = 1:length(fr)
    % どれか一つでも検索結果がある
    if ~isempty(fr(i).Object)
        % タグ文字列 'TAG: '
        tag_str = sprintf('%s: ', fr(i).Tag);
        % タグ文字列 'TAG: 'の文字数
        tag_str_len = length(tag_str);
        
        % テキストの抽出
        text_buf = cellfun(@fetch_text, fr(i).Object, 'UniformOutput',false);
        % コメント(タグを除外)を抽出
        com_buf = cellfun(@(t) t(tag_str_len+1:end), text_buf, 'UniformOutput', false);
        % パスを抽出
        path_buf = cellfun(@(x) x.Path, fr(i).Object, 'UniformOutput', false);
        % ハンドルを抽出
        h_buf = cellfun(@(x) x.Handle, fr(i).Object);
        % 数値ハンドル(double)をHEX値(cell(char))に変換
        handle_hex_buf = arrayfun(@num2hex, h_buf, 'UniformOutput', false);


        tag_disp_str = sprintf('[%s]', fr(i).Tag);
        % [Tag]カラムのフィールド幅
        tag_field_width = max(length(tag_disp_str), 8);

        % disp表示
        fprintf('----  ')
        % [Tag]カラムのフィールド幅はtag_field_width分確保('-' は Unicode 45 で行列を作って出力)
        fprintf('%s', char(zeros(1, tag_field_width) + 45))
        fprintf('  ---------------\n')

        fprintf('No    %-*s  Annotation Path\n', tag_field_width, '[Tag]')
        for j = 1:length(fr(i).Object)
            fprintf('----  ')
            % [Tag]カラムのフィールド幅はtag_field_width分確保('-' は Unicode 45 で行列を作って出力)
            fprintf('%s', char(zeros(1, tag_field_width) + 45))
            fprintf('  ---------------\n')
    
            fprintf( ...
                '%-4d  %-*s  <a href="matlab:focus_slannotation(''%s'')">%s</a>\n', ...
                j, ...
                tag_field_width, ...
                tag_disp_str, ...
                handle_hex_buf{j}, ...
                path_buf{j} ...
            )
            disp(com_buf{j})
        end
    end
end





