import pandas as pd
import pprint
from datetime import datetime, timedelta


def main():
    table_df = pd.read_csv('forums_23.csv')
    tree_df = pd.read_csv('final_format_tree/all_links_0423.csv', low_memory = False)
    date_cols = [i for i in tree_df.columns.values if 'date' in i]
    print date_cols
    tree_date_df = pd.read_csv('final_format_tree/all_links_0423.csv', parse_dates = date_cols, infer_datetime_format = True, low_memory = False)

    subtree_lengths = pd.read_csv('final_format_tree/subtree_lengths.csv', index_col = 0)
    path = 'Final_LDA_results/'

    code_dict = {'core_P': 1, 'core_R': 2, 'core_PR': 3, 'core_RP': 3, 'pheriphery_P': 4, 'pheriphery_R': 5, 'pheriphery_PR': 6,
                 'pheriphery_RP': 6,
                 'xpheriphery_P': 7, 'xpheriphery_R': 8, 'xpheriphery_PR': 9, 'xpheriphery_RP': 9}

    result = dict()
    sorted_all_links = pd.DataFrame()
    sorted_max_trees = pd.DataFrame()

    for t in table_df['table'].tolist():
        print t
        lda_file_path = path + t + '_lda.csv'
        lda_df = pd.read_csv(lda_file_path, index_col = 0)
        max_topic_id = max(lda_df['topic_id'].unique())

        for tid in range(0, max_topic_id+1):
            ft = t + '_topic' + str(tid)
            result[ft] = {}

            subtrees = subtree_lengths[ft].tolist()
            subtrees = [i for i in subtrees if i==i] # remove NaN
            max_tree_id = subtrees.index(max(subtrees)) # get subtree id of the longest tree, if ties, take the 1st one

            pid = ft +'_p_uniqueid'
            pdate = ft +'_p_date'
            pitem = ft +'_p_item'
            cid = ft +'_c_uniqueid'
            cdate = ft +'_c_date'
            citem = ft +'_c_item'
            subtree_title = ft + '_subtreeid'
            selected_cols = [pid, pdate, pitem, cid, cdate, citem, subtree_title]
            selected_selected_cols = [pid, pdate, pitem, cid, cdate, citem]
            tdf = tree_date_df[selected_cols]
            tdf.dropna(subset = [cid], inplace = True)
            tdf_sorted = tdf.sort_values(by = [pdate, cdate])
            tdf_sorted.reset_index(inplace = True, drop = True)
            sorted_all_links = sorted_all_links.join(tdf_sorted[selected_selected_cols], how = 'outer')

            max_subtree = tdf_sorted[tdf_sorted[subtree_title]==max_tree_id]
            max_subtree.reset_index(inplace=True, drop = True)
            sorted_max_trees = sorted_max_trees.join(max_subtree[selected_selected_cols], how = 'outer')

            tdf_pindex = pd.DatetimeIndex(tdf_sorted[pdate])
            tdf_cindex = pd.DatetimeIndex(tdf_sorted[cdate])
            tdf_psorted = tdf_sorted
            tdf_csorted = tdf_sorted
            tdf_psorted.index = tdf_pindex
            tdf_csorted.index = tdf_cindex
            tdf_csorted.sort_index(inplace=True)

            topic_start_date = tdf_sorted[pdate][0]
            topic_end_date = tdf_csorted[cdate][-1]
            days = (topic_end_date - topic_start_date).days
            if days >= 90*20:
                num_segment = 20
                seg_length = days/20
            else:
                num_segment = days/90
                seg_length = 90

            seg_dates = [topic_start_date]
            for i in range(1, num_segment):
                cut_date = topic_start_date + timedelta(days = seg_length*i)
                seg_dates.append(cut_date)
            seg_dates.append(topic_end_date)
            for index, d in enumerate(seg_dates[1:]):
                #print seg_dates[index-1], d
                segment_df = tdf_csorted[seg_dates[index-1]:d]
                for row in segment_df.iterrows():
                    child_code = code_dict[row[1][citem]]
                    if row[1][pid] == row[1][pid]: # parent exists
                        parent_code = code_dict[row[1][pitem]]
                    else:
                        parent_code = 10
                    pair = 'seg_' + str(index) + '_' + str(parent_code) + '-' + str(child_code)
                    if pair in result[ft]:
                        result[ft][pair] += 1
                    else:
                        result[ft][pair] = 1

    print sorted_all_links.shape
    result_df = pd.DataFrame.from_dict(result, orient='index')
    print result_df.shape
    result_df.to_csv('final_format_tree/final_format_tree_0424.csv')
    sorted_all_links.to_csv('final_format_tree/time_sorted_all_links_0424.csv')
    sorted_max_trees.to_csv('final_format_tree/sorted_max_subtrees_0424.csv')


if __name__=="__main__":
    pd.set_option('chained_assignment', None)
    main()