import matplotlib.pyplot as plt
import numpy as np

# Stats for Ester, All For One, and Toga
categories = [
    "Speed", "Attack", "Defense", "Intelligence", "Collaboration", 
    "Stamina", "Stealth", "Awareness", "Willpower", "Charisma", "Agility"
]

ester_stats = [60, 30, 23, 99, 5, 13, 50, 79, 80, 70, 73]
all_for_one_stats = [92, 99, 99, 96, 50, 85, 60, 95, 85, 90, 80]
toga_stats = [85, 65, 45, 70, 60, 75, 90, 80, 70, 75, 85]

# Bar positions
x = np.arange(len(categories))
width = 0.25

# Plotting the stats
fig, ax = plt.subplots(figsize=(12, 6))

ax.bar(x - width, ester_stats, width, label='Ester Glacier', color='skyblue')
ax.bar(x, all_for_one_stats, width, label='All For One', color='crimson')
ax.bar(x + width, toga_stats, width, label='Himiko Toga', color='gold')

# Adding labels and legend
ax.set_xlabel('Stats', fontsize=14)
ax.set_ylabel('Percentage', fontsize=14)
ax.set_title('Stat Comparison: Ester, All For One, and Toga', fontsize=16)
ax.set_xticks(x)
ax.set_xticklabels(categories, rotation=45, ha='right')
ax.legend()

# Display the graph
plt.tight_layout()
plt.show()