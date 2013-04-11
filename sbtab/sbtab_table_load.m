function sbtab = sbtab_table_load(filename)

% sbtab = sbtab_table_load(filename)

my_table = load_unformatted_table(filename);

attribute_line = {};
if strcmp('!!',my_table{1,1}(1:2)), 
 attribute_line = my_table(1,:);
 my_table       = my_table(2:end,:);
end

rows = struct;
ind_data = [];
if size(my_table,1)>1,
  while strcmp('!',my_table{2,1}(1)), 
    row_header = my_table{2,1}(2:end);
    row_rest   = [{[]},my_table(2,2:end)];
    ind_data   = [ind_data, find(cellfun('length',row_rest))];
    my_table   = my_table([1,3:end],:);
    rows       = setfield(rows,row_header,row_rest);
  end
end

ind_rows = setdiff(unique(ind_data),1);

column = struct;
ind_column = [];
for it = 1:size(my_table,2),
  column_header = my_table{1,it};
  if strcmp('!',column_header(1)),
    column_header = column_header(2:end);
    if strfind(column_header,'ID'),
      column_header = strrep(column_header,' ','_');
      column_header = strrep(column_header,'-','_');
      column_header = strrep(column_header,'','_');
      column_header = strrep(column_header,':','_');
      column_header = strrep(column_header,'.','_');
    end
    ind_column = [ind_column it];
    column = setfield(column,column_header,my_table(2:end,it));
  end
end

ind_data         = setdiff(ind_rows,ind_column);
data_headers     = my_table(1,ind_data);
data             = my_table(2:end,ind_data);


ind_uncontrolled = setdiff(1:size(my_table,2),[ind_column,ind_data]);
if length(ind_uncontrolled),
  uncontrolled_headers = my_table(1,ind_uncontrolled);
  uncontrolled         = my_table(2:end,ind_uncontrolled);
else
  uncontrolled_headers = [];
  uncontrolled         = [];
  ind_uncontrolled = [];
end

fn = fieldnames(rows);

data_attributes   = [];
column_attributes = [];

for it = 1:length(fn);
  data_attributes.(fn{it})   = rows.(fn{it})(ind_data);
  column_attributes.(fn{it}) = rows.(fn{it})(ind_column);
end

attributes = struct;
if length(attribute_line), attribute_line{1}=strrep(attribute_line{1},'!!SBtab ',''); end
for it=1:length(attribute_line),
 mm = strsplit('=',attribute_line{it});
 if length(mm) ==2,
   attributes = setfield(attributes,mm{1},mm{2});
 end
end

sbtab.filename          = filename;
sbtab.attributes        = attributes;
sbtab.rows              = rows;
sbtab.column.column     = column;
sbtab.column.attributes = column_attributes;
sbtab.column.ind        = ind_column;
sbtab.data.headers      = data_headers;
sbtab.data.attributes   = data_attributes;
sbtab.data.data         = data;
sbtab.data.ind          = ind_data;
sbtab.uncontrolled.headers = uncontrolled_headers;
sbtab.uncontrolled.data = uncontrolled;
sbtab.uncontrolled.ind  = ind_uncontrolled;