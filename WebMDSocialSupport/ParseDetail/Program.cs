using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.VisualBasic.FileIO;

namespace ParseDetail
{
    class Program
    {
        static void Main(string[] args)
        {
            using (var parser = new TextFieldParser(args[0]))
            {
                parser.TextFieldType = FieldType.Delimited;
                parser.SetDelimiters(",");
                string[] title = parser.ReadFields();
                while (!parser.EndOfData) {
                    string[] fields = parser.ReadFields();
                    Cutline(fields, title);
                }
            }
        }

        private static void Cutline(string[] fields, string[] title)
        {
            for (int i = 0; i < 188; ++i) {
                if (string.IsNullOrWhiteSpace(fields[i * 6])) continue;
                string fileName = string.Format(@"d:\temp\ForumTree\detail\{0}.csv", title[i * 6].Replace("_date", ""));
                using (var writer = new StreamWriter(fileName, true)) {
                    writer.WriteLine("{0},{1},{2},{3}", fields[i * 6], fields[i * 6 + 1], fields[i * 6 + 2], fields[i * 6 + 5]);
                }
            }
        }
    }
}
