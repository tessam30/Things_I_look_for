# pie is for eating

pies <- 
  tibble::tribble(
   ~pies, ~n, ~prop,
   "Pie graphs I make",  1,  0.01,
  "Pie graphs I will never make", 99,  0.99
  )

ggplot(pies, aes(x = "", y = prop, fill = pies)) +
  geom_bar(width = 1, stat = "identity", color = "white") +
  coord_polar("y", start = 0) +
  geom_label_repel(aes(label = n), color = "white") +
  scale_fill_viridis_d(direction = -1, begin = 0.75, end = 0.5) +
  theme_void() +
  theme(legend.position = "top") +
  labs(fill = "Pie graphs I will make")
  

