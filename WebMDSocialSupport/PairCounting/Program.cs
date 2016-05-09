using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.VisualBasic.FileIO;

namespace PairCounting
{
    class Program
    {
        static string[] topics = new string[] {
            "add_and_adhd_exchange_topic0",
            "add_and_adhd_exchange_topic1",
            "add_and_adhd_exchange_topic2",
            "add_and_adhd_exchange_topic3",
            "add_and_adhd_exchange_topic4",
            "add_and_adhd_exchange_topic5",
            "add_and_adhd_exchange_topic6",
            "alzheimers_exchange_topic0",
            "alzheimers_exchange_topic1",
            "alzheimers_exchange_topic2",
            "alzheimers_exchange_topic3",
            "alzheimers_exchange_topic4",
            "alzheimers_exchange_topic5",
            "alzheimers_exchange_topic6",
            "asthma_exchange_topic0",
            "asthma_exchange_topic1",
            "asthma_exchange_topic2",
            "asthma_exchange_topic3",
            "asthma_exchange_topic4",
            "asthma_exchange_topic5",
            "asthma_exchange_topic6",
            "asthma_exchange_topic7",
            "back_pain_exchange_topic0",
            "back_pain_exchange_topic1",
            "back_pain_exchange_topic2",
            "back_pain_exchange_topic3",
            "back_pain_exchange_topic4",
            "back_pain_exchange_topic5",
            "back_pain_exchange_topic6",
            "back_pain_exchange_topic7",
            "breast_cancer_exchange_topic0",
            "breast_cancer_exchange_topic1",
            "breast_cancer_exchange_topic2",
            "breast_cancer_exchange_topic3",
            "breast_cancer_exchange_topic4",
            "breast_cancer_exchange_topic5",
            "breast_cancer_exchange_topic6",
            "breast_cancer_exchange_topic7",
            "cholesterol_management_exchange_topic0",
            "cholesterol_management_exchange_topic1",
            "cholesterol_management_exchange_topic2",
            "cholesterol_management_exchange_topic3",
            "cholesterol_management_exchange_topic4",
            "cholesterol_management_exchange_topic5",
            "cholesterol_management_exchange_topic6",
            "cholesterol_management_exchange_topic7",
            "cholesterol_management_exchange_topic8",
            "cholesterol_management_exchange_topic9",
            "cholesterol_management_exchange_topic10",
            "cholesterol_management_exchange_topic11",
            "cholesterol_management_exchange_topic12",
            "cholesterol_management_exchange_topic13",
            "cholesterol_management_exchange_topic14",
            "cholesterol_management_exchange_topic15",
            "cholesterol_management_exchange_topic16",
            "cholesterol_management_exchange_topic17",
            "cholesterol_management_exchange_topic18",
            "cholesterol_management_exchange_topic19",
            "diabetes_exchange_topic0",
            "diabetes_exchange_topic1",
            "diabetes_exchange_topic2",
            "diabetes_exchange_topic3",
            "diabetes_exchange_topic4",
            "diabetes_exchange_topic5",
            "diet_exchange_topic0",
            "diet_exchange_topic1",
            "diet_exchange_topic2",
            "diet_exchange_topic3",
            "diet_exchange_topic4",
            "diet_exchange_topic5",
            "diet_exchange_topic6",
            "diet_exchange_topic7",
            "diet_exchange_topic8",
            "digestive_disorders_exchange_topic0",
            "digestive_disorders_exchange_topic1",
            "digestive_disorders_exchange_topic2",
            "digestive_disorders_exchange_topic3",
            "digestive_disorders_exchange_topic4",
            "digestive_disorders_exchange_topic5",
            "digestive_disorders_exchange_topic6",
            "epilepsy_exchange_topic0",
            "epilepsy_exchange_topic1",
            "epilepsy_exchange_topic2",
            "epilepsy_exchange_topic3",
            "epilepsy_exchange_topic4",
            "epilepsy_exchange_topic5",
            "epilepsy_exchange_topic6",
            "epilepsy_exchange_topic7",
            "epilepsy_exchange_topic8",
            "fibromyalgia_exchange_topic0",
            "fibromyalgia_exchange_topic1",
            "fibromyalgia_exchange_topic2",
            "fibromyalgia_exchange_topic3",
            "fibromyalgia_exchange_topic4",
            "fibromyalgia_exchange_topic5",
            "fibromyalgia_exchange_topic6",
            "fibromyalgia_exchange_topic7",
            "fibromyalgia_exchange_topic8",
            "fitness_and_exercise_exchange_topic0",
            "fitness_and_exercise_exchange_topic1",
            "fitness_and_exercise_exchange_topic2",
            "fitness_and_exercise_exchange_topic3",
            "fitness_and_exercise_exchange_topic4",
            "fitness_and_exercise_exchange_topic5",
            "fitness_and_exercise_exchange_topic6",
            "fitness_and_exercise_exchange_topic7",
            "fitness_and_exercise_exchange_topic8",
            "hepatitis_exchange_topic0",
            "hepatitis_exchange_topic1",
            "hepatitis_exchange_topic2",
            "hepatitis_exchange_topic3",
            "hepatitis_exchange_topic4",
            "hiv_and_aids_exchange_topic0",
            "hiv_and_aids_exchange_topic1",
            "hiv_and_aids_exchange_topic2",
            "hiv_and_aids_exchange_topic3",
            "hiv_and_aids_exchange_topic4",
            "hiv_and_aids_exchange_topic5",
            "hiv_and_aids_exchange_topic6",
            "hiv_and_aids_exchange_topic7",
            "menopause_exchange_topic0",
            "menopause_exchange_topic1",
            "menopause_exchange_topic2",
            "menopause_exchange_topic3",
            "menopause_exchange_topic4",
            "menopause_exchange_topic5",
            "menopause_exchange_topic6",
            "menopause_exchange_topic7",
            "menopause_exchange_topic8",
            "multiple_sclerosis_exchange_topic0",
            "multiple_sclerosis_exchange_topic1",
            "multiple_sclerosis_exchange_topic2",
            "multiple_sclerosis_exchange_topic3",
            "multiple_sclerosis_exchange_topic4",
            "osteoporosis_exchange_topic0",
            "osteoporosis_exchange_topic1",
            "osteoporosis_exchange_topic2",
            "osteoporosis_exchange_topic3",
            "osteoporosis_exchange_topic4",
            "osteoporosis_exchange_topic5",
            "osteoporosis_exchange_topic6",
            "osteoporosis_exchange_topic7",
            "osteoporosis_exchange_topic8",
            "osteoporosis_exchange_topic9",
            "pain_management_exchange_topic0",
            "pain_management_exchange_topic1",
            "pain_management_exchange_topic2",
            "pain_management_exchange_topic3",
            "pain_management_exchange_topic4",
            "pain_management_exchange_topic5",
            "pain_management_exchange_topic6",
            "pain_management_exchange_topic7",
            "pain_management_exchange_topic8",
            "parenting_exchange_topic0",
            "parenting_exchange_topic1",
            "parenting_exchange_topic2",
            "parenting_exchange_topic3",
            "parenting_exchange_topic4",
            "parenting_exchange_topic5",
            "parenting_exchange_topic6",
            "parkinsons_disease_exchange_topic0",
            "parkinsons_disease_exchange_topic1",
            "parkinsons_disease_exchange_topic2",
            "parkinsons_disease_exchange_topic3",
            "parkinsons_disease_exchange_topic4",
            "parkinsons_disease_exchange_topic5",
            "relationships_and_coping_community_topic0",
            "relationships_and_coping_community_topic1",
            "relationships_and_coping_community_topic2",
            "relationships_and_coping_community_topic3",
            "relationships_and_coping_community_topic4",
            "relationships_and_coping_community_topic5",
            "relationships_and_coping_community_topic6",
            "sexual_conditions_and_stds_exchange_topic0",
            "sexual_conditions_and_stds_exchange_topic1",
            "sexual_conditions_and_stds_exchange_topic2",
            "sexual_conditions_and_stds_exchange_topic3",
            "sexual_conditions_and_stds_exchange_topic4",
            "sexual_conditions_and_stds_exchange_topic5",
            "sexual_conditions_and_stds_exchange_topic6",
            "sexual_conditions_and_stds_exchange_topic7",
            "sexual_conditions_and_stds_exchange_topic8",
            "sex_and_relationships_exchange_topic0",
            "sex_and_relationships_exchange_topic1",
            "sex_and_relationships_exchange_topic2",
            "sex_and_relationships_exchange_topic3",
            "sex_and_relationships_exchange_topic4",
            "sex_and_relationships_exchange_topic5",
        };

        static void Main(string[] args)
        {
            string treeFile = string.Format(@"D:\temp\ForumTree\tree\{0}.csv", args[0]);

            var count = new Dictionary<Tuple<string, int, int, int>, int>();
            using (var parser = new TextFieldParser(treeFile))
            {
                parser.TextFieldType = FieldType.Delimited;
                parser.SetDelimiters(",");
                while (!parser.EndOfData)
                {
                    string[] fields = parser.ReadFields();
                    string topic = fields[0];
                    int section = int.Parse(fields[1]);
                    int ptype = int.Parse(fields[3]);
                    int ctype = int.Parse(fields[6]);
                    var key = Tuple.Create(topic, section, ptype, ctype);
                    if (count.ContainsKey(key))
                    {
                        ++count[key];
                    }
                    else
                    {
                        count.Add(key, 1);
                    }
                }
            }

            foreach (var t in topics)
            {
                for (int s = 1; s <= 20; ++s)
                {
                    for (int ptype = 0; ptype <= 9; ++ptype)
                    {
                        for (int ctype = 0; ctype <= 9; ++ctype)
                        {
                            if (ptype == 0 && ctype == 0) continue;
                            var key = Tuple.Create(t, s, ptype, ctype);
                            Console.Write("{0},", count.ContainsKey(key) ? count[key] : 0);
                        }
                    }
                }
                Console.WriteLine();
            }
        }
    }
}