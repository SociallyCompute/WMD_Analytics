import numpy as np
from gensim import corpora, models
import pandas as pd
import string
from nltk.tokenize import word_tokenize, RegexpTokenizer
from nltk.stem import PorterStemmer
from stop_words import get_stop_words

stemmerPorter = PorterStemmer()
# create English stop words list
with open('stop.txt', 'r') as f:
    en_stop = f.read().splitlines()
# en_stop = get_stop_words('en')
tokenizer = RegexpTokenizer(r'\w+')

table_df = pd.read_csv('forums_23.csv')
#print table_df['table'].tolist()
path = 'LDA/'

n_topics = range(2, 10)


def get_doc_word_matrix(data_df):
    #doc_dict = dict()
    texts = []
    for row in data_df.iterrows():
        docID = row[0]
        if row[1]['content'] == row[1]['content']:
            text = row[1]['content'].lower()
        else:
            text = ''
        tokens = get_token(text)
        filtered_words = [w for w in tokens if w not in en_stop and w not in string.punctuation and len(w)>2] # remove single and two-letter words
        stemmed_words = [stemmerPorter.stem(w) for w in filtered_words]
        texts.append(stemmed_words)

    word_id_map = corpora.Dictionary(texts)
    doc_word_matrix = [word_id_map.doc2bow(text) for text in texts] #bow: bag-of-words
    return word_id_map, doc_word_matrix

def get_token(text):
    clean_text = "";
    for word in text.split():
        if "<ADO>" in word:
            continue
        if "<UD>" in word:
            continue
        illegal = r'/\%*|<>@{}()[]'
        if any(elem in word for elem in illegal):
            continue
        clean_text += (word + " ")
    tokens = tokenizer.tokenize(clean_text)
    return tokens

for t in table_df['table'].tolist():
    print t
    file_path = path + t + '.csv'
    data_df = pd.read_csv(file_path, encoding = 'utf-8')
    word_id_map, doc_word_matrix = get_doc_word_matrix(data_df)
    perps = []
    for nt in n_topics:
        lda_model = models.ldamodel.LdaModel(doc_word_matrix, num_topics=nt, id2word = word_id_map, passes=5)
        perplexity = np.exp2(-lda_model.log_perplexity(doc_word_matrix))
        perps.append(perplexity)

    perps_df=pd.DataFrame(perps, columns=['perplexity'])
    perps_df['num_topic']=perps_df.apply(lambda row: row.name +2, axis = 1)
    perps_df.to_csv('lda_results_topic_up_to20/'+t+'_perplexity.csv')

    picked_nt = perps.index(min(perps))+2
    print perps, picked_nt
    lda_model = models.ldamodel.LdaModel(doc_word_matrix, num_topics=picked_nt, id2word = word_id_map, passes=5)

    data_df['topic_id'] = data_df.apply(lambda row:lda_model[doc_word_matrix[row.name]][0][0], axis = 1 )
    data_df.to_csv('lda_results_topic_up_to20/'+t+'_lda.csv', encoding='utf-8')

    word_topic_distribution = []
    for k in range(picked_nt):
        word_topic_distribution.append(lda_model.show_topic(k))
    word_topic_df = pd.DataFrame(word_topic_distribution)
    word_topic_df.to_csv('lda_results_topic_up_to20/'+t+'_word_topic.csv')
