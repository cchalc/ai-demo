FROM jupyter/scipy-notebook

RUN mkdir my-model

ENV MODEL_DIR=/home/jovyan/my-model
ENV MODEL_FILE_LDA=clf_lda.joblib
ENV MODEL_FILE_NN=clf_nn.joblib

COPY src/requirements.txt  requirements.txt
RUN pip install -r requirements.txt

COPY src/ .

RUN python3 train.py
