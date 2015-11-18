import neko.Lib;

class Main
{
  var line: String;
  public function new()
    {
      var buf = new StringBuf();
      for (i in 0...78)
        buf.add('=');
      buf.add('\n\n');
      line = buf.toString();
    }


  public function run()
    {
      var args = Sys.args();
      if (args.length < 2)
        {
          Sys.println('Usage: neko run.n <input file> <output file>');
          return;
        }
      var inputName = args[0];
      var outputName = args[1];

      var str = sys.io.File.getContent(inputName);
      var buf = new StringBuf();
      buf.add(outputName + '\tFor Vim version 7.4\tLast change: 2015\n');
      buf.add('*' + outputName + '*\n');

      var xml = Xml.parse(str);
      var root = xml.firstChild();
      for (cl in root.elements())
        {
          buf.add(line);
          buf.add('Class *' + cl.get('path') + '*\n\n');

          var hasExt = false;
          for (ext in cl.elementsNamed('extends'))
            {
              buf.add('extends: |' + ext.get('path') + '| ');
              hasExt = true;
            }
          if (hasExt)
            buf.add('\n\n');

          for (doc in cl.elementsNamed('haxe_doc'))
            {
              buf.add('' + doc.firstChild());
              buf.add('\n\n');
            }

          for (field in cl.elements())
            {
              if (Lambda.has([ 'meta', '__f', 'extends' ], field.nodeName ))
                continue;

              if(field.get('public') != "1" || field.get('override') == "1")
                continue;

              buf.add('*' + cl.get('path') + '.' + field.nodeName + '*\n');
              if (field.get('set') == 'method')
                buf.add('function ');
              buf.add(field.nodeName);
              if (field.get('set') == 'method')
                {
                  var f = field.firstElement();
                  var fieldNamesStr = f.get('a');
                  var fieldValuesStr = f.get('v');

                  var fieldNames = [];
                  if (fieldNamesStr != null)
                    fieldNames = fieldNamesStr.split(':');

                  var fieldValues = [];
                  if (fieldValuesStr != null)
                    fieldValues = fieldValuesStr.split(':');

                  var fieldPaths = [];
//                  Lib.print(f.get('a') + ' ' + f.get('v'));
                  for (type in f.elements())
                    fieldPaths.push(type.get('path'));
//                    Lib.print(type.get('path'));

                  buf.add('(');
                  for (i in 0...fieldNames.length)
                    buf.add(fieldNames[i] + ': ' + fieldPaths[i] +
                      (fieldValues[i] != 'null' && fieldValues[i] != '' ? ' = ' + fieldValues[i] : '') +
                      (i < fieldNames.length - 1 ? ', ' : ''));
                  buf.add(')');
                  if (fieldPaths.length > fieldNames.length)
                    buf.add(': ' + fieldPaths[fieldPaths.length - 1]);
                }

              else
                {
                  for (e in field.elementsNamed('c'))
                    buf.add(': |' + e.get('path') + '|');
                }
              buf.add('\n\n');
              for (e in field.elementsNamed('haxe_doc'))
                {
                  buf.add(e.firstChild());
                  buf.add('\n\n');
                }
            }
        }

      buf.add('vim:fen:tw=78:et:ts=8:ft=help:norl:\n');
      sys.io.File.saveContent(outputName, buf.toString());
    }


  public static function main()
    {
      var inst = new Main();
      inst.run();
    }
}
