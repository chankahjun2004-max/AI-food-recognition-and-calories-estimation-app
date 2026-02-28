class NutrientInfo {
  final double calories;
  final double protein;
  final double fat;
  final double carbs;

  const NutrientInfo({
    required this.calories,
    required this.protein,
    required this.fat,
    required this.carbs,
  });
}

final Map<String, NutrientInfo> nutrientDatabase = {
  "Apam Balik":
      const NutrientInfo(calories: 280, protein: 6.0, fat: 11.0, carbs: 40.0),
  "Bean Sprout":
      const NutrientInfo(calories: 30, protein: 3.0, fat: 0.2, carbs: 6.0),
  "Beef Rendang":
      const NutrientInfo(calories: 210, protein: 18.0, fat: 14.0, carbs: 5.0),
  "Boil Pork Slices":
      const NutrientInfo(calories: 160, protein: 25.0, fat: 6.5, carbs: 0.0),
  "Boiled Egg":
      const NutrientInfo(calories: 155, protein: 13.0, fat: 11.0, carbs: 1.1),
  "Char Siew":
      const NutrientInfo(calories: 250, protein: 19.0, fat: 14.0, carbs: 12.0),
  "Chee Cheong Fun":
      const NutrientInfo(calories: 110, protein: 1.5, fat: 0.5, carbs: 24.0),
  "Chicken Rice (Rice only)":
      const NutrientInfo(calories: 160, protein: 3.5, fat: 6.0, carbs: 23.0),
  "Chicken Rice": const NutrientInfo(
      calories: 607,
      protein: 25.0,
      fat: 20.0,
      carbs:
          80.0), // fallback average based on old data or combination since model might just say "Chicken Rice"
  "Chicken Satay":
      const NutrientInfo(calories: 190, protein: 18.0, fat: 11.0, carbs: 6.0),
  "Satay": const NutrientInfo(
      calories: 35, protein: 3.0, fat: 1.5, carbs: 2.0), // from old mapped data
  "Chinese Poach Chicken":
      const NutrientInfo(calories: 165, protein: 23.0, fat: 8.0, carbs: 0.0),
  "Chinese Sausage":
      const NutrientInfo(calories: 480, protein: 15.0, fat: 42.0, carbs: 10.0),
  "Curry (Gravy only)":
      const NutrientInfo(calories: 120, protein: 2.0, fat: 10.0, carbs: 6.0),
  "Curry Chicken":
      const NutrientInfo(calories: 180, protein: 16.0, fat: 11.0, carbs: 4.0),
  "Eggplant (Fried/Sautéed)":
      const NutrientInfo(calories: 90, protein: 1.0, fat: 7.0, carbs: 6.0),
  "Fish Ball":
      const NutrientInfo(calories: 95, protein: 12.0, fat: 1.5, carbs: 8.0),
  "Fish Cake":
      const NutrientInfo(calories: 110, protein: 13.0, fat: 3.5, carbs: 7.0),
  "Fried Anchovies":
      const NutrientInfo(calories: 280, protein: 45.0, fat: 8.0, carbs: 2.0),
  "Fried Banana":
      const NutrientInfo(calories: 250, protein: 2.0, fat: 12.0, carbs: 35.0),
  "Fried Chicken":
      const NutrientInfo(calories: 280, protein: 22.0, fat: 18.0, carbs: 8.0),
  "Fried Dumpling":
      const NutrientInfo(calories: 240, protein: 9.0, fat: 13.0, carbs: 22.0),
  "Fried Egg":
      const NutrientInfo(calories: 195, protein: 13.0, fat: 15.0, carbs: 1.0),
  "Fried Fu Cuk":
      const NutrientInfo(calories: 450, protein: 20.0, fat: 35.0, carbs: 15.0),
  "Fried Kuey Teow":
      const NutrientInfo(calories: 185, protein: 5.0, fat: 9.0, carbs: 21.0),
  "Fried Rice":
      const NutrientInfo(calories: 175, protein: 4.5, fat: 7.0, carbs: 24.0),
  "Fried Squid":
      const NutrientInfo(calories: 210, protein: 16.0, fat: 11.0, carbs: 12.0),
  "Garlic (Raw)":
      const NutrientInfo(calories: 149, protein: 6.4, fat: 0.5, carbs: 33.0),
  "Green Vegetables (Stir-fry)":
      const NutrientInfo(calories: 60, protein: 2.5, fat: 4.0, carbs: 4.0),
  "Keropok Lekor (Fried)":
      const NutrientInfo(calories: 240, protein: 14.0, fat: 10.0, carbs: 23.0),
  "Maggie Noodle (Cooked)":
      const NutrientInfo(calories: 140, protein: 3.0, fat: 6.0, carbs: 19.0),
  "Minced Pork":
      const NutrientInfo(calories: 240, protein: 17.0, fat: 19.0, carbs: 0.0),
  "Murtabak (Beef/Chicken)":
      const NutrientInfo(calories: 220, protein: 10.0, fat: 11.0, carbs: 20.0),
  "Mushroom (Shiitake)":
      const NutrientInfo(calories: 35, protein: 2.0, fat: 0.5, carbs: 7.0),
  "Nasi Kerabu (Mixed)":
      const NutrientInfo(calories: 145, protein: 5.0, fat: 4.0, carbs: 22.0),
  "Nasi Lemak (Rice only)":
      const NutrientInfo(calories: 175, protein: 3.5, fat: 8.5, carbs: 21.0),
  "Nasi Lemak": const NutrientInfo(
      calories: 644, protein: 16.0, fat: 22.0, carbs: 90.0), // fallback average
  "Pan Mee Noodle (Dry)":
      const NutrientInfo(calories: 350, protein: 10.0, fat: 2.0, carbs: 72.0),
  "Peanut (Roasted)":
      const NutrientInfo(calories: 567, protein: 25.0, fat: 49.0, carbs: 16.0),
  "Peanut Sauce":
      const NutrientInfo(calories: 250, protein: 7.0, fat: 18.0, carbs: 16.0),
  "Pineapple":
      const NutrientInfo(calories: 50, protein: 0.5, fat: 0.1, carbs: 13.0),
  "Poach Egg":
      const NutrientInfo(calories: 143, protein: 12.5, fat: 9.5, carbs: 0.7),
  "Pork Ball":
      const NutrientInfo(calories: 210, protein: 14.0, fat: 15.0, carbs: 5.0),
  "Pork Lard (Crispy bits)":
      const NutrientInfo(calories: 800, protein: 2.0, fat: 85.0, carbs: 0.0),
  "Pork Ribs (Cooked)":
      const NutrientInfo(calories: 260, protein: 20.0, fat: 18.0, carbs: 0.0),
  "Prawn (Steamed)":
      const NutrientInfo(calories: 99, protein: 21.0, fat: 1.1, carbs: 0.2),
  "Rice Noodle (Kuey Teow)":
      const NutrientInfo(calories: 140, protein: 2.0, fat: 0.3, carbs: 32.0),
  "Roasted Chicken":
      const NutrientInfo(calories: 220, protein: 24.0, fat: 13.0, carbs: 0.5),
  "Roti Canai (Plain)":
      const NutrientInfo(calories: 320, protein: 7.0, fat: 14.0, carbs: 42.0),
  "Roti Canai": const NutrientInfo(
      calories: 300, protein: 7.0, fat: 10.0, carbs: 46.0), // fallback average
  "Salted Egg":
      const NutrientInfo(calories: 185, protein: 13.0, fat: 14.0, carbs: 1.5),
  "Sambal (with oil)":
      const NutrientInfo(calories: 200, protein: 3.0, fat: 15.0, carbs: 14.0),
  "Sambal Squid":
      const NutrientInfo(calories: 170, protein: 15.0, fat: 9.0, carbs: 8.0),
  "Sliced Cucumber":
      const NutrientInfo(calories: 15, protein: 0.7, fat: 0.1, carbs: 3.6),
  "Sliced Red Onion":
      const NutrientInfo(calories: 40, protein: 1.1, fat: 0.1, carbs: 9.0),
  "Sliced Tomato":
      const NutrientInfo(calories: 18, protein: 0.9, fat: 0.2, carbs: 3.9),
  "Soup Dumpling (Siew Mai)":
      const NutrientInfo(calories: 180, protein: 10.0, fat: 9.0, carbs: 15.0),
  "Stuffed Chili Pepper":
      const NutrientInfo(calories: 120, protein: 6.0, fat: 8.0, carbs: 7.0),
  "Tau Pok (Stuffed Beancurd)":
      const NutrientInfo(calories: 220, protein: 14.0, fat: 16.0, carbs: 5.0),
  "Ulam-Ulaman":
      const NutrientInfo(calories: 20, protein: 1.5, fat: 0.2, carbs: 3.0),
  "Wan Tan Mee Noodle (Dry)":
      const NutrientInfo(calories: 170, protein: 5.0, fat: 6.0, carbs: 24.0),
  "White Rice (Steamed)":
      const NutrientInfo(calories: 130, protein: 2.7, fat: 0.3, carbs: 28.0),
  "Yellow Noodle":
      const NutrientInfo(calories: 150, protein: 4.0, fat: 1.5, carbs: 30.0),
  "You Tiao":
      const NutrientInfo(calories: 410, protein: 7.0, fat: 25.0, carbs: 40.0),

  // Previously used values in `vm_insight.dart` not explicitly in new table just so it doesn't break
  "Teh Tarik":
      const NutrientInfo(calories: 83, protein: 2.0, fat: 3.0, carbs: 12.0),
  "Curry Mee":
      const NutrientInfo(calories: 500, protein: 15.0, fat: 25.0, carbs: 55.0),
  "Curry Puff":
      const NutrientInfo(calories: 128, protein: 2.0, fat: 7.0, carbs: 14.0),
  "Mee Goreng":
      const NutrientInfo(calories: 500, protein: 10.0, fat: 20.0, carbs: 70.0),
  "Kuih":
      const NutrientInfo(calories: 150, protein: 1.5, fat: 5.0, carbs: 25.0),
};
