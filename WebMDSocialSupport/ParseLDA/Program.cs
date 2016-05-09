using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.VisualBasic.FileIO;

namespace ParseLDA
{
    class Program
    {
        static Dictionary<Tuple<string, string>, int> typeMapping = new Dictionary<Tuple<string, string>, int>();

        static void Init()
        {
            typeMapping.Add(Tuple.Create("Core", "P"), 1);
            typeMapping.Add(Tuple.Create("Core", "R"), 2);
            typeMapping.Add(Tuple.Create("Core", "RP"), 3);
            typeMapping.Add(Tuple.Create("Periphery", "P"), 4);
            typeMapping.Add(Tuple.Create("Periphery", "R"), 5);
            typeMapping.Add(Tuple.Create("Periphery", "RP"), 6);
            typeMapping.Add(Tuple.Create("XPeriphery", "P"), 7);
            typeMapping.Add(Tuple.Create("XPeriphery", "R"), 8);
            typeMapping.Add(Tuple.Create("XPeriphery", "RP"), 9);
        }

        static void Main(string[] args)
        {
            Init();

            string originalFile = string.Format(@"D:\Dropbox\Forum Tree\Original_files\{0}.csv", args[0]);
            string ldaFile = string.Format(@"D:\Dropbox\Forum Tree\Final_LDA_results\{0}_lda.csv", args[0]);
            string typeFile = string.Format(@"D:\Dropbox\Forum Tree\Core_periphery_and_xperiphery_data\{0}.csv", args[0]);

            var coreUser = new HashSet<string>();
            var peripheryUser = new HashSet<string>();
            using (var parser = new TextFieldParser(typeFile))
            {
                parser.TextFieldType = FieldType.Delimited;
                parser.SetDelimiters(",");
                if (!parser.EndOfData) parser.ReadFields();
                while (!parser.EndOfData)
                {
                    string[] fields = parser.ReadFields();
                    if (!string.IsNullOrWhiteSpace(fields[0]))
                    {
                        coreUser.Add(fields[0]);
                    }
                    if (!string.IsNullOrWhiteSpace(fields[1]))
                    {
                        peripheryUser.Add(fields[1]);
                    }
                }
            }

            var lda = new Dictionary<string, Tuple<string, string, int>>();
            using (var parser = new TextFieldParser(ldaFile))
            {
                parser.TextFieldType = FieldType.Delimited;
                parser.SetDelimiters(",");
                if (!parser.EndOfData) parser.ReadFields();
                while (!parser.EndOfData)
                {
                    string[] fields = parser.ReadFields();
                    lda.Add(fields[1], Tuple.Create(fields[5], fields[9], int.Parse(fields[10])));
                }
            }

            var origin = new Dictionary<string, Tuple<string, DateTime, string>>();
            using (var parser = new TextFieldParser(originalFile))
            {
                parser.TextFieldType = FieldType.Delimited;
                parser.SetDelimiters(",");
                if (!parser.EndOfData) parser.ReadFields();
                while (!parser.EndOfData)
                {
                    string[] fields = parser.ReadFields();
                    origin.Add(fields[0], Tuple.Create(fields[4], DateTime.Parse(fields[5]), fields[6]));
                }
            }

            foreach (var id in origin.Keys)
            {
                string parentId = origin[id].Item3;
                string childId = id;
                string parentUser = parentId == "NULL" ? "NULL" : origin[parentId].Item1;
                string childUser = origin[id].Item1;
                int parentType = parentId == "NULL" ? 0 : typeMapping[Tuple.Create(GetUserType(parentUser, coreUser, peripheryUser), GetPostType(parentId, lda))];
                int childType = typeMapping[Tuple.Create(GetUserType(childUser, coreUser, peripheryUser), GetPostType(childId, lda))];
                int topic = GetTopic(id, lda);
                string parsedFile = string.Format(@"d:\temp\ForumTree\data\{0}_topic{1}.csv", args[0], topic);
                using (var writer = new StreamWriter(parsedFile, true))
                {
                    writer.WriteLine("{0},{1},{2},{3},{4},{5},{6}", origin[childId].Item2, childId, childUser, childType, parentId, parentUser, parentType);
                }
            }

            //foreach (var id in origin.Keys)
            //{
            //    string parentId = origin[id].Item3;
            //    string childId = id;
            //    string parentUser = parentId == "NULL" ? "NULL" : origin[parentId].Item1;
            //    string childUser = origin[id].Item1;
            //    int parentType = parentId == "NULL" ? 0 : typeMapping[Tuple.Create(GetUserType(parentUser, coreUser, peripheryUser), GetPostType(parentId, lda))];
            //    int childType = typeMapping[Tuple.Create(GetUserType(childUser, coreUser, peripheryUser), GetPostType(childId, lda))];
            //    Console.WriteLine("{0},{1},{2},{3},{4},{5}", parentId, parentType, origin[id].Item2, childId, childType, origin[id].Item2);
            //}
        }

        private static int GetTopic(string id, Dictionary<string, Tuple<string, string, int>> lda)
        {
            if (lda.ContainsKey(id)) return lda[id].Item3;
            return 0;
        }

        private static string GetUserType(string user, HashSet<string> coreUser, HashSet<string> peripheryUser)
        {
            if (coreUser.Contains(user)) return "Core";
            else if (peripheryUser.Contains(user)) return "Periphery";
            else return "XPeriphery";
        }

        private static string GetPostType(string id, Dictionary<string, Tuple<string, string, int>> lda)
        {
            return lda.ContainsKey(id) ? lda[id].Item2 : "R";
        }
    }
}
