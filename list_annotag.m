function [varargout] = list_annotag(mdl, tag)
%LIST_ANNOTAG �A�m�e�[�V�����^�O�t���R�����g�̈ꗗ�\��
% Simulink���f�����̒��߂ŁA'TODO: ...' ����n�܂�g�A�m�e�[�V�����^�O�t���R�����g�h���������A
% MATLAB�R�}���h�E�C���h�E�Ɉꗗ�\�����܂��B
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
%     �����Ώۂ̃V�X�e�����w�肵�܂��B
%     �ȗ������ꍇ�́A���݃A�N�e�B�u�ȃ��f�� 'bdroot' �������Ώۂɂ��܂��B
% tag    [char | 1xN cell(char)]
%     �����Ώۂ̃^�O���w�肵�܂��B
%     ��: 'FIXME'
%         {'FIXME', 'MEMO'}
%     �ȗ������ꍇ�́A�ȉ��̃f�t�H���g�̃^�O���������܂��B
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
% ��   tag���ƂɃO���[�s���O�����������ʂ��i�[
% ��   N��tag�Ŏw�肵�������^�O�̐��B
% ������ Tag    [Char]
% ��       �^�O���B
% ������ Object    [1xM cell(Simulink.Annotation�I�u�W�F�N�g)]
%         �����Ńq�b�g�������߃I�u�W�F�N�g
% 

% �f�t�H���g�����^�O�̒�`
defaulttag = {'TODO', 'FIXME', 'XXX', 'REVIEW', 'OPTIMIZE', 'CHANGED', 'NOTE', 'WARNING'};

% �����̐��̃`�F�b�N
switch nargin
    case 0
        mdl = bdroot;
        tag = defaulttag;
    case 1
        % ���� mdl ����w��̏ꍇ�́Abdroot���i�[
        if isempty(mdl)
            mdl = bdroot;
        end
        tag = defaulttag;
    case 2
        % ���� mdl ����w��̏ꍇ�́Abdroot���i�[
        if isempty(mdl)
            mdl = bdroot;
        end
        % ���� tag ��������̏ꍇ�� 1x1 cell�Ɋi�[������
        if ischar(tag)
            tag = {tag};
        end
    otherwise
        error('list_annotag:arg_check_failed', '�����̐�������������I');
end

% �A�m�e�[�V�����^�O�t���R�����g�̌���
finded_result = find_annotag(mdl, tag);
% �A�m�e�[�V�����^�O�t���R�����g���ꗗ�\��
show_annotag(finded_result);

% �Ԃ�l�̊i�[
% �Ăяo�����ŏo�͈������w�肳��Ă���ꍇ�́Afinded_result�\���̂𓊂��Ԃ�
if nargout == 1
    varargout{1} = finded_result;
end


function [fr] = find_annotag(mdl, tag)
%FIND_ANNOTAG �A�m�e�[�V�����^�O�t���R�����g������
% Simulink���f�����̒��߂ŁA'TODO: ...' ����n�܂�g�A�m�e�[�V�����^�O�t���R�����g�h���������܂��B
%
% fr = find_annotag(mdl, tag)
%
% [input]
% mdl    [char]
%     �����Ώۂ̃V�X�e�����w�肵�܂��B
% tag    [1xN cell(char)]
%     �����Ώۂ̃^�O���w�肵�܂��B
%     ��: {'FIXME', 'MEMO'}
%
% [output]
% fr    [1xN Struct]
% ��   �������ʊi�[�\����
% ������ Tag    [Char]
% ��       �^�O���B
% ������ Object    [1xM cell(Simulink.Annotation�I�u�W�F�N�g)]
%         �����Ńq�b�g�������߃I�u�W�F�N�g

% ���ׂĂ̒��߂̃n���h�����擾
h = find_system(mdl, 'FindAll', 'on', 'Variants', 'AllVariants', 'type', 'annotation');
% �n���h������ASimulink.Annotation �I�u�W�F�N�g�̎擾
anno_obj = get_param(h, 'Object');
% ���߂�2�ȏ�̏ꍇ�̓Z���z��Ɋi�[���ꂽ
% Simulink.Annotation �I�u�W�F�N�g���Ԃ��Ă��邯�ǁA
% ���߂�1�̏ꍇ��Simulink.Annotation �I�u�W�F�N�g��
% �Ԃ��Ă��邽�߁A1x1�Z���z��ɕϊ�����
if ~iscell(anno_obj)
    anno_obj = {anno_obj};
end
% ���߃e�L�X�g
text = cellfun(@fetch_text, anno_obj, 'UniformOutput',false);

% �������ʊi�[�\����
fr = struct( ...
    'Tag', tag, ...
    'Object', [] ...
);

% ����
for i = 1:length(fr)
    % �^�O������ 'TAG: '
    tag_str = sprintf('%s: ', fr(i).Tag);
    % �^�O������ 'TAG: '�̕�����
    tag_str_len = length(tag_str);
    % �e�L�X�g����A�m�e�[�V�����^�O������
    idx = cellfun(@(x) strncmp(x, tag_str, tag_str_len), text);
    % ���߃I�u�W�F�N�g�ƃe�L�X�g�𒊏o
    fr(i).Object = anno_obj(idx);
end


function txt = fetch_text(obj)
%FETCH_TEXT Simulink.Annotation�I�u�W�F�N�g���璍�߃e�L�X�g���擾����
% PlainText�v���p�e�B�����݂���ꍇ��PlainText����擾�B
% PlainText�v���p�e�B�����݂��Ȃ��ꍇ(�Â�Ver�ɂ͑��݂��Ȃ�)��Text����擾�B
% 
% [input]
% obj    [Simulink.Annotation �I�u�W�F�N�g]
%     Simulink.Annotation�I�u�W�F�N�g
% 
% [output]
% txt    [char]
%     ���߃e�L�X�g

if isprop(obj, 'PlainText')
    txt = obj.PlainText;
else
    txt = obj.Text;
end


function show_annotag(fr)
%SHOW_ANNOTAG �A�m�e�[�V�����^�O�t���R�����g�̈ꗗ�\��
% Simulink���f�����̒��߂ŁA'TODO: ...' �Ȃǂ���n�܂�g�A�m�e�[�V�����^�O�t���R�����g�h��
% MATLAB�R�}���h�E�C���h�E��Ɉꗗ�\�����܂��B
% 
% show_annotag(fr)
% 
% [input]
% fr    [1xN struct]
%     �������ʍ\����

% �^�O���ƂɃ��[�v
for i = 1:length(fr)
    % �ǂꂩ��ł��������ʂ�����
    if ~isempty(fr(i).Object)
        % �^�O������ 'TAG: '
        tag_str = sprintf('%s: ', fr(i).Tag);
        % �^�O������ 'TAG: '�̕�����
        tag_str_len = length(tag_str);
        
        % �e�L�X�g�̒��o
        text_buf = cellfun(@fetch_text, fr(i).Object, 'UniformOutput',false);
        % �R�����g(�^�O�����O)�𒊏o
        com_buf = cellfun(@(t) t(tag_str_len+1:end), text_buf, 'UniformOutput', false);
        % �p�X�𒊏o
        path_buf = cellfun(@(x) x.Path, fr(i).Object, 'UniformOutput', false);
        % �n���h���𒊏o
        h_buf = cellfun(@(x) x.Handle, fr(i).Object);
        % ���l�n���h��(double)��HEX�l(cell(char))�ɕϊ�
        handle_hex_buf = arrayfun(@num2hex, h_buf, 'UniformOutput', false);


        tag_disp_str = sprintf('[%s]', fr(i).Tag);
        % [Tag]�J�����̃t�B�[���h��
        tag_field_width = max(length(tag_disp_str), 8);

        % disp�\��
        fprintf('----  ')
        % [Tag]�J�����̃t�B�[���h����tag_field_width���m��('-' �� Unicode 45 �ōs�������ďo��)
        fprintf('%s', char(zeros(1, tag_field_width) + 45))
        fprintf('  ---------------\n')

        fprintf('No    %-*s  Annotation Path\n', tag_field_width, '[Tag]')
        for j = 1:length(fr(i).Object)
            fprintf('----  ')
            % [Tag]�J�����̃t�B�[���h����tag_field_width���m��('-' �� Unicode 45 �ōs�������ďo��)
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





