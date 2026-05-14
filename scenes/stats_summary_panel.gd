extends Panel

func display(stats: MealStats):
	%Harga.text = "Harga: " + str(stats.harga)
	%Karbohidrat.text = "Karbo: " + str(stats.karbo)
	%Protein.text = "Protein: " + str(stats.protein)
	%Vitamin.text = "Vitamin: " + str(stats.vitamin)
	%Gula.text = "Gula: " + str(stats.gula)
	%Lemak.text = "Lemak: " + str(stats.lemak)
