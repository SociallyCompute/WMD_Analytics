using Microsoft.VisualBasic.FileIO;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace ForumTree
{
    class Program
    {
        static Dictionary<Tuple<string, string>, List<DateTime>> interactPair = new Dictionary<Tuple<string, string>, List<DateTime>>();
        static Dictionary<string, List<Tuple<string, DateTime>>> attendThread = new Dictionary<string, List<Tuple<string, DateTime>>>();
        static Dictionary<string, int> idType = new Dictionary<string, int>();
        static Dictionary<string, DateTime> idTime = new Dictionary<string, DateTime>();

        static void Main(string[] args)
        {
            string dataFile = string.Format(@"D:\temp\ForumTree\data\{0}.csv", args[0]);
            string detailFile = string.Format(@"D:\temp\ForumTree\detail\{0}.csv", args[0]);

            using (var parser = new TextFieldParser(dataFile))
            {
                parser.TextFieldType = FieldType.Delimited;
                parser.SetDelimiters(",");
                while (!parser.EndOfData)
                {
                    string[] fields = parser.ReadFields();
                    DateTime time = DateTime.Parse(fields[0]);
                    string id = fields[1];
                    string name = fields[2];
                    int type = int.Parse(fields[3]);
                    string rid = fields[4];
                    string rname = fields[5];
                    int rtype = int.Parse(fields[6]);
                    if (!idType.ContainsKey(id))
                    {
                        idType.Add(id, type);
                    }
                    if (!idTime.ContainsKey(id))
                    {
                        idTime.Add(id, time);
                    }
                    if (interactPair.ContainsKey(Tuple.Create(name, rname)))
                    {
                        interactPair[Tuple.Create(name, rname)].Add(time);
                    }
                    else
                    {
                        interactPair.Add(Tuple.Create(name, rname), new List<DateTime>() {time});
                    }
                    string thread = id.Split('_')[0];
                    if (attendThread.ContainsKey(name))
                    {
                        attendThread[name].Add(Tuple.Create(thread, time));
                    }
                    else
                    {
                        attendThread.Add(name, new List<Tuple<string, DateTime>>() { Tuple.Create(thread, time) });
                    }
                }
            }

            var pairs = new List<Tuple<string, int, DateTime, string, int, DateTime>>();
            var idHasChild = new HashSet<string>();
            DateTime startTime = new DateTime();
            using (var parser = new TextFieldParser(detailFile))
            {
                parser.TextFieldType = FieldType.Delimited;
                parser.SetDelimiters(",");
                var prev = new List<Tuple<DateTime,string,string>>();
                var strength = new Dictionary<Tuple<string, string>, int>();
                if (!parser.EndOfData)
                {
                    string[] fields = parser.ReadFields();
                    startTime = DateTime.Parse(fields[0]);
                    prev.Add(Tuple.Create(startTime, fields[1], fields[3]));
                    pairs.Add(Tuple.Create("NULL", 0, startTime, fields[3], idType[fields[3]], startTime));
                }
                while (!parser.EndOfData)
                {
                    string[] fields = parser.ReadFields();
                    DateTime time = DateTime.Parse(fields[0]);
                    string id = fields[3];
                    string name = fields[1];
                    var parentCandidate = new Dictionary<Tuple<string, DateTime>, int>();
                    int length = prev.Count;
                    for (int i = length - 1; i >= 0; --i)
                    {
                        Tuple<DateTime, string, string> p = prev[i];
                        if ((time - p.Item1).TotalDays > 30) break;
                        int s = CalculateStrength(name, p.Item2, p.Item1);
                        if (s == 0) continue;
                        if (parentCandidate.Count == 0) parentCandidate.Add(Tuple.Create(p.Item3, p.Item1), s);
                        else if (s > parentCandidate.First().Value)
                        {
                            parentCandidate.Clear();
                            parentCandidate.Add(Tuple.Create(p.Item3, p.Item1), s);
                        }
                        else if (s == parentCandidate.First().Value)
                        {
                            parentCandidate.Add(Tuple.Create(p.Item3, p.Item1), s);
                        }
                    }
                    if (parentCandidate.Count == 0)
                    {
                        pairs.Add(Tuple.Create("NULL", 0, time, id, idType[id], time));
                    }
                    else if (parentCandidate.Count == 1)
                    {
                        string pid = parentCandidate.First().Key.Item1;
                        DateTime ptime = parentCandidate.First().Key.Item2;
                        int ptype = idType[pid];
                        int type = idType[id];
                        pairs.Add(Tuple.Create(pid, ptype, ptime, id, idType[id], time));
                        if (!idHasChild.Contains(pid)) idHasChild.Add(pid);
                    }
                    else
                    {
                        Random rand = new Random();
                        Tuple<string, DateTime> key = parentCandidate.ElementAt(rand.Next(parentCandidate.Count)).Key;
                        string pid = key.Item1;
                        DateTime ptime = key.Item2;
                        int ptype = idType[pid];
                        int type = idType[id];
                        pairs.Add(Tuple.Create(pid, ptype, ptime, id, idType[id], time));
                        if (!idHasChild.Contains(pid)) idHasChild.Add(pid);
                    }
                    prev.Add(Tuple.Create(time, name, id));
                }
            }

            foreach (var t in idTime.Keys)
            {
                if (idHasChild.Contains(t)) continue;
                pairs.Add(Tuple.Create(t, idType[t], idTime[t], "NULL", 0, idTime[t]));
            }

            pairs.Sort((x, y) => x.Item3.CompareTo(y.Item3));
            TimeSpan totalSpan = pairs.Last().Item3 - pairs.First().Item3;
            int sectionDays = totalSpan.TotalDays > 1800 ? (int)(totalSpan.TotalDays / 20) + 1 : 90;
            foreach (var p in pairs)
            {
                TimeSpan span = p.Item3 - startTime;
                int sectionIndex = (int)(span.TotalDays / sectionDays) + 1;
                Console.WriteLine("{0},{1},{2},{3},{4},{5},{6},{7}", args[0], sectionIndex, p.Item1, p.Item2, p.Item3, p.Item4, p.Item5, p.Item6);
            }
        }

        private static int CalculateStrength(string cname, string pname, DateTime ptime)
        {
            if (Interacted(cname, pname, ptime))
            {
                return 2;
            }
            else if (AttendedSameThread(cname, pname, ptime))
            {
                return 1;
            }
            else
            {
                return 0;
            }
        }

        private static bool Interacted(string cname, string pname, DateTime ptime)
        {
            if (interactPair.ContainsKey(Tuple.Create(cname, pname)) &&
                interactPair.ContainsKey(Tuple.Create(pname, cname)))
            {
                int tsCount = interactPair[Tuple.Create(cname, pname)].Where(t => t > ptime && (t - ptime).TotalDays < 90).Count() +
                    interactPair[Tuple.Create(pname, cname)].Where(t => t > ptime && (t - ptime).TotalDays < 90).Count();
                return tsCount > 0;
            }
            else if (interactPair.ContainsKey(Tuple.Create(cname, pname)))
            {
                int tsCount = interactPair[Tuple.Create(cname, pname)].Where(t => t > ptime && (t - ptime).TotalDays < 90).Count();
                return tsCount > 0;
            }
            else if (interactPair.ContainsKey(Tuple.Create(pname, cname)))
            {
                int tsCount = interactPair[Tuple.Create(pname, cname)].Where(t => t > ptime && (t - ptime).TotalDays < 90).Count();
                return tsCount > 0;
            }
            else
            {
                return false;
            }
        }

        private static bool AttendedSameThread(string cname, string pname, DateTime ptime)
        {
            if (attendThread.ContainsKey(cname) && attendThread.ContainsKey(pname))
            {
                HashSet<string> cthreads = new HashSet<string>(attendThread[cname].Where(t => t.Item2 > ptime && (t.Item2 - ptime).TotalDays < 30).Select(t => t.Item1));
                HashSet<string> pthreads = new HashSet<string>(attendThread[pname].Where(t => t.Item2 > ptime && (t.Item2 - ptime).TotalDays < 30).Select(t => t.Item1));
                int count = cthreads.Intersect(pthreads).Count();
                return count > 0;
            }
            else
            {
                return false;
            }
        }
    }
}
