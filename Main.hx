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
          Sys.println('Usage: neko run.n <input file> <output directory>');
          return;
        }
      var inputName = args[0];
      var outputDir = args[1];

      var str = sys.io.File.getContent(inputName);
      var xml = Xml.parse(str);
      var root = xml.firstChild();

      for (cl in root.elements())
        {
          var buf = new StringBuf();
          var outputName = outputDir + cl.get('path') + '.txt';
          var date = DateTools.format(Date.now(), "%d.%m.%Y");
          buf.add(cl.get('path') + '.txt' + '\tFor Vim version 7.4\tLast change: ' + date + '\n');
          buf.add('*' + cl.get('path') + '.txt' + '*\n');

          buf.add(line);
          buf.add(cl.nodeName + ' *' + cl.get('path') + '*\n');
          var module = cl.get('module');
          if (module != null)
            buf.add('defined in |' + module + '|\n');
          buf.add('\n');

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
              buf.add(convertDoc('' + doc.firstChild()));
              buf.add('\n\n');
            }

          var elements = null;
          if (cl.nodeName == 'class' || cl.nodeName == 'enum')
            elements = cl.elements();
          else if (cl.nodeName == 'abstract')
            elements = cl.elements();
          else if (cl.nodeName == 'typedef')
            {
              elements = cl.firstElement().elements();
              if (elements == null)
                elements = cl.elements();
            }

          for (field in elements)
            {
              if (Lambda.has([ 'meta', '__f', 'extends' ], field.nodeName ))
                continue;

              if (cl.nodeName != 'typedef')
                if (field.get('public') != "1" ||
                  field.get('override') == "1")
                continue;

              // meta tags
              var doContinue = false;
              for (meta in field.elementsNamed('meta'))
                {
                  var m = meta.firstElement();

                  // dox:hide
                  if (m.get('n') == ':dox')
                    {
                      var x = '' + m.firstElement().firstChild();
                      if (x == 'hide')
                        doContinue = true;
                    }
                }
              if (doContinue)
                continue;

              buf.add('*' + cl.get('path') + '.' + field.nodeName + '*\n');

              // check if it's a function
              var isFunc = false;
              for (e in field.elementsNamed('f'))
                {
                  isFunc = true;
                  break;
                }

//              if (field.get('set') == 'method')
              if (isFunc)
                buf.add('public function ');
              else buf.add('public var ');
              buf.add(field.nodeName);
              if (isFunc)
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
                    if (type.nodeName == 'd')
                      fieldPaths.push('Dynamic');
                    else fieldPaths.push(type.get('path'));
//                    Lib.print(type.get('path'));

                  buf.add('(');
                  for (i in 0...fieldNames.length)
                    buf.add(fieldNames[i] + ': |' + fieldPaths[i] + '|' +
                      ((i < fieldValues.length && fieldValues[i] != '') ?
                        ' = ' + fieldValues[i] : '') +
                      (i < fieldNames.length - 1 ? ', ' : ''));
                  buf.add(')');
                  if (fieldPaths.length > fieldNames.length)
                    buf.add(': |' + fieldPaths[fieldPaths.length - 1] + '|');
                }

              // property
              else
                {
                  for (e in field.elements())
                    if (Lambda.has([ 'c', 't', 'x' ], e.nodeName))
                      buf.add(': |' + e.get('path') + '|');
                }
              buf.add(';\n\n');
              for (e in field.elementsNamed('haxe_doc'))
                {
                  buf.add(convertDoc('' + e.firstChild()));
                  buf.add('\n\n');
                }
            }

          buf.add('vim:fen:tw=78:et:ts=8:ft=help:norl:\n');
          sys.io.File.saveContent(outputName, buf.toString());
        }
    }

  function convertDoc(txt: String): String
    {
//      txt = StringTools.replace(txt, '`', '|');
      return txt;
    }

  public static function main()
    {
      var inst = new Main();
      inst.run();
    }
}
