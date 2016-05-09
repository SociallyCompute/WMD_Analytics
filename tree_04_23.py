import pandas as pd
from datetime import datetime, timedelta
import pprint
import random
import numpy as np

def main():
    table_df = pd.read_csv('forums_23.csv')
    #print table_df['table'].tolist()
    path = 'Final_LDA_results/'
    group_path = 'Core_periphery_and_xperiphery_data/'
    oringal_path = 'Original_files/'

    code_dict = {'core_P': 1, 'core_R': 2, 'core_PR': 3, 'core_RP': 3, 'pheriphery_P': 4, 'pheriphery_R': 5, 'pheriphery_PR': 6,
                 'pheriphery_RP': 6,
                 'xpheriphery_P': 7, 'xpheriphery_R': 8, 'xpheriphery_PR': 9, 'xpheriphery_RP': 9}

    all_links_result = dict()
    subtree_lengths = dict()

    for t in table_df['table'].tolist():
        print t

        lda_file_path = path + t + '_lda.csv'
        group_file_path = group_path + t + '.csv'
        original_file_path = oringal_path + t + '.csv'

        lda_df = pd.read_csv(lda_file_path, parse_dates = ['date'], infer_datetime_format= True, index_col = 0)
        lda_datetime_index = pd.DatetimeIndex(lda_df['date'])
        lda_df.index = lda_datetime_index
        lda_df.sort_index(inplace = True)

        original_df = pd.read_csv(original_file_path, parse_dates = ['date'], infer_datetime_format = True, index_col = 0)
        original_datetime_index = pd.DatetimeIndex(original_df['date'])
        original_df.index = original_datetime_index
        original_df.sort_index(inplace = True)

        group_df = pd.read_csv(group_file_path)
        core = set([x for x in group_df['core'].unique() if x==x])
        periphery = set([x for x in group_df['periphery'].unique() if x==x])

        max_topic_id = max(lda_df['topic_id'].unique())

        for tid in range(0, max_topic_id+1):
            pid = t + '_topic' + str(tid)+'_p_uniqueid'
            pdate = t + '_topic' + str(tid)+'_p_date'
            pitem = t + '_topic' + str(tid)+'_p_item'

            cid = t + '_topic' + str(tid)+'_c_uniqueid'
            cdate = t + '_topic' + str(tid)+'_c_date'
            citem = t + '_topic' + str(tid)+'_c_item'

            subtree_title = t + '_topic' + str(tid) + '_subtreeid'

            all_links_result[pid] = {}
            all_links_result[pdate] = {}
            all_links_result[pitem] = {}
            all_links_result[cid] = {}
            all_links_result[cdate] = {}
            all_links_result[citem] = {}
            all_links_result[subtree_title] = {}

            subtree_lengths[t+'_topic'+str(tid)] = {}

            pairid = 0
            subtree_id = 0

            cdf = lda_df[lda_df['topic_id']==tid]
            topic_start_date = cdf['date'][0]
            topic_end_date = cdf['date'][-1]
            first_month_end = topic_start_date + timedelta(days = 90)
            first_month_df = cdf[topic_start_date: first_month_end]
            first_month_len = len(first_month_df)
            if len(first_month_df) < len(cdf):
                after_first_month_df = cdf.iloc[first_month_len:]
            else:
                after_first_month_df = pd.DataFrame() # make it empty so no looping will happen

            nodes = [] # the queue of the nodes

            for fr in first_month_df.iterrows():
                unique_id = fr[1]['uniqueID']
                post_date = fr[1]['date']
                poster = fr[1]['poster']
                info = fr[1]['information']
                item_name = get_item_name(poster, info, core, periphery)
                node = {'unique_id': unique_id, 'post_date': post_date, 'poster': poster, 'item': item_name}

                if len(nodes)==0:
                    nodes.append(node)
                else:
                    max_strength = 0
                    max_strength_pairs = []
                    for pn in nodes:
                        link_strength = get_link_strength(pn, node, original_df)
                        if link_strength > 0 and link_strength >= max_strength:
                            max_strength = link_strength
                            max_strength_pairs.append((pn, node))
                    if max_strength > 0:
                        nodes.append(node)
                        if len(max_strength_pairs) == 1:
                            current_pair = max_strength_pairs[0]
                        else:
                            current_pair = random.choice(max_strength_pairs)
                    else:
                        empty_parent = {'unique_id': np.nan, 'post_date': node['post_date'], 'item': np.nan} # set parent as empty but with children timestamp
                        current_pair = (empty_parent, node)
                        subtree_lengths[t+'_topic'+str(tid)][subtree_id] = len(nodes)
                        subtree_id += 1
                        del nodes[:]
                        nodes = []
                        nodes.append(node) # restart a new subtree
                    all_links_result[pid][pairid] = current_pair[0]['unique_id']
                    all_links_result[pdate][pairid] = current_pair[0]['post_date']
                    all_links_result[pitem][pairid] = current_pair[0]['item']
                    all_links_result[cid][pairid] = current_pair[1]['unique_id']
                    all_links_result[cdate][pairid] = current_pair[1]['post_date']
                    all_links_result[citem][pairid] = current_pair[1]['item']
                    all_links_result[subtree_title][pairid] = subtree_id
                    pairid += 1

            if subtree_id ==0 and len(nodes)==1 and len(after_first_month_df)==0: # if the whole topic only has one post
                all_links_result[pid][pairid] = np.nan
                all_links_result[pdate][pairid] = nodes[0]['post_date']
                all_links_result[pitem][pairid] = np.nan
                all_links_result[cid][pairid] = nodes[0]['unique_id']
                all_links_result[cdate][pairid] = nodes[0]['post_date']
                all_links_result[citem][pairid] = nodes[0]['item']
                subtree_lengths[t+'_topic'+str(tid)][subtree_id] = 1

            subtree_nodes = nodes #subtree_nodes is used for keeping the subtree node lengths, shouldn't pop nodes
            for r in after_first_month_df.iterrows():
                unique_id = r[1]['uniqueID']
                post_date = r[1]['date']
                poster = r[1]['poster']
                info = r[1]['information']
                item_name = get_item_name(poster, info, core, periphery)
                node = {'unique_id': unique_id, 'post_date': post_date, 'poster': poster, 'item': item_name}

                if len(nodes)>0: # moved .pop to later, so nodes length is at least 1
                    max_strength = 0
                    max_strength_pairs = []
                    for pn in nodes:
                        link_strength = get_link_strength(pn, node, original_df)
                        if link_strength > 0 and link_strength >= max_strength:
                            max_strength = link_strength
                            max_strength_pairs.append((pn, node))
                    if max_strength > 0:
                        if len(max_strength_pairs) == 1:
                            current_pair = max_strength_pairs[0]
                        else:
                            current_pair = random.choice(max_strength_pairs)
                    else:
                        empty_parent = {'unique_id': np.nan, 'post_date': node['post_date'], 'item': np.nan} # set parent as empty but with children timestamp
                        current_pair = (empty_parent, node)
                        subtree_lengths[t+'_topic'+str(tid)][subtree_id] = len(subtree_nodes)
                        subtree_id += 1
                        #del nodes[:] if completely delete this, this will influence subtree_nodes
                        nodes = [] # restart a new subtree
                        subtree_nodes = []

                    nodes.append(node)
                    subtree_nodes.append(node)
                    if len(nodes)>1:
                        nodes.pop(0) # only pop when new nodes are added
                    all_links_result[pid][pairid] = current_pair[0]['unique_id']
                    all_links_result[pdate][pairid] = current_pair[0]['post_date']
                    all_links_result[pitem][pairid] = current_pair[0]['item']
                    all_links_result[cid][pairid] = current_pair[1]['unique_id']
                    all_links_result[cdate][pairid] = current_pair[1]['post_date']
                    all_links_result[citem][pairid] = current_pair[1]['item']
                    all_links_result[subtree_title][pairid] = subtree_id
                    pairid += 1

            subtree_lengths[t+'_topic'+str(tid)][subtree_id] = len(subtree_nodes) # the last subtree

    pprint.pprint(subtree_lengths)
    subtree_lengths_df = pd.DataFrame.from_dict(subtree_lengths)
    subtree_lengths_df.to_csv('final_format_tree/subtree_lengths.csv')
    result_df = pd.DataFrame.from_dict(all_links_result)
    print result_df.shape
    result_df.to_csv('final_format_tree/all_links_0423.csv')

def get_link_strength(node1, node2, original_df):
    # node 1 is parent
    poster1 = node1['poster']
    poster2 = node2['poster']
    date1 = node1['post_date']
    date2 = node2['post_date']
    one_month_cut = date1 + timedelta(days = 30) # interaction has to happen within a month of parent node
    original_df_one_month = original_df[date1: one_month_cut]
    poster1_replyto = original_df_one_month[original_df_one_month['poster'] == poster1]['replyTo'].unique()
    poster2_replyto = original_df_one_month[original_df_one_month['poster'] == poster2]['replyTo'].unique()

    if poster1 in poster2_replyto or poster2 in poster1_replyto:
        return 3
    else:
        poster1_titles = set(original_df_one_month[original_df_one_month['poster'] == poster1]['title'].unique())
        poster2_titles = set(original_df_one_month[original_df_one_month['poster'] == poster2]['title'].unique())
        if len(poster1_titles.intersection(poster2_titles)) > 0:
            return 2

    if (date2 - date1).days<=30: # if happens within the same month
        return 1
    else:
        return 0


def get_item_name(poster, info, core, periphery):
    if poster in core:
        content = 'core_' + info
    elif poster in periphery:
        content = 'pheriphery_' + info
    else:
        content = 'xpheriphery_' + info
    return content


if __name__ == "__main__":
    main()