#!/usr/bin/env python3
import matplotlib.pyplot as plt
from sklearn.decomposition import PCA
from gensim.models import Word2Vec
import numpy as np

# Sample sentences to train a small Word2Vec model for illustration
sentences = [
    ["data", "science", "machine", "learning", "deep", "learning", "neural", "network"],
    ["artificial", "intelligence", "AI", "robotics", "automation"],
    ["python", "java", "programming", "coding", "software", "development"],
    ["statistics", "probability", "mathematics", "modeling", "analysis"],
    ["algorithm", "optimization", "performance", "efficiency"],
    ["cloud", "computing", "AWS", "Azure", "GCP"],
    ["database", "SQL", "NoSQL", "MongoDB", "PostgreSQL", "database"],
    ["cybersecurity", "encryption", "firewall", "network", "security"],
    ["blockchain", "bitcoin", "cryptocurrency", "decentralized", "ledger"],
]

# Train a small Word2Vec model
model = Word2Vec(sentences, vector_size=10, window=3, min_count=1, sg=1)

# Select some words for 3D plotting and extract their embeddings
words = [
    "data",
    "science",
    "AI",
    "python",
    "statistics",
    "algorithm",
    "cloud",
    "cybersecurity",
    "blockchain",
]
embeddings = np.array([model.wv[word] for word in words])

# Reduce embeddings to 3D for visualization
pca = PCA(n_components=3)
reduced_embeddings = pca.fit_transform(embeddings)

# Plotting in 3D
fig = plt.figure(figsize=(10, 7))
ax = fig.add_subplot(111, projection="3d")

# Scatter plot
ax.scatter(
    reduced_embeddings[:, 0],
    reduced_embeddings[:, 1],
    reduced_embeddings[:, 2],
    color="blue",
    s=50,
)

# Label each point
for i, word in enumerate(words):
    ax.text(
        reduced_embeddings[i, 0],
        reduced_embeddings[i, 1],
        reduced_embeddings[i, 2],
        word,
        size=12,
        color="black",
    )

# Set plot parameters
ax.set_xlabel("PCA 1")
ax.set_ylabel("PCA 2")
ax.set_zlabel("PCA 3")
ax.set_title("3D Plot of Word2Vec Embeddings with Semantic Relationships")

plt.show()
