module puzzles.puzzle21;

import std.conv, std.string, std.range, std.stdio, std.format, std.ascii;
import std.algorithm;
import std.math;
import core.atomic;
import std.parallelism : parallel;
import core.stdc.string : strlen;
import utilities.inputparser;

class Registration
{
    string[] m_name;
    int[] m_count;
    int[string] m_register;

    void Register(string name)
    {
        if ((name in m_register) == null)
        {
            int index = cast(int)m_name.length;
            m_register[name] = index;
            m_name ~= name;
            m_count ~= 1;
        }
        else
        {
            int index = m_register[name];
            m_count[index] += 1;
        }
    }

    void Clear()
    {
        m_name.length = 0;
        m_count.length = 0;
        m_register.clear;
    }

    int Count()
    {
        return cast(int)m_name.length;
    }

    int GetCount(int index)
    {
        return m_count[index];
    }

    string GetName(int index)
    {
        return m_name[index];
    }
}

class Ingredient
{
    this(string name)
    {
        m_name = name;
        m_used_by_how_many_foods = 0;
    }

    string Name()
    {
        return m_name;
    }

    void Used()
    {
        m_used_by_how_many_foods += 1;
    }

    int GetUsed()
    {
        return m_used_by_how_many_foods;
    }

    void PossiblyAffectedByAllergen(string name_of_allergen)
    {
        m_name_of_allergen_in_food ~= name_of_allergen;
    }

    bool ContainsAllergen()
    {
        return m_name_of_allergen_in_food.length > 0;
    }

    string[] NameOfAllergen()
    {
        return m_name_of_allergen_in_food;
    }

    void Print()
    {
        if (ContainsAllergen())
        {
            writeln(m_name_of_allergen_in_food, " appears in ", m_name);
        }
        else
        {
            //writeln("'", m_name, "'");
        }
    }

    string m_name;
    string[] m_name_of_allergen_in_food;
    int[string] m_allergens;
    int m_used_by_how_many_foods;
}

class Allergen
{
    this(string name)
    {
        m_name = name;
    }

    string Name()
    {
        return m_name;
    }

    void Print()
    {
        writeln("'", m_name, "'",);
    }

    string m_name;
}

class Food
{
    this()
    {
    }

    Ingredient[] m_ingredients;
    Allergen[] m_allergens;

    void AddIngredient(Ingredient item)
    {
        item.Used();
        m_ingredients ~= item;
    }

    void AddAllergen(Allergen item)
    {
        m_allergens ~= item;
    }

    bool ContainsAllergen(string name)
    {
        foreach(allergen; m_allergens)
        {
            if (allergen.Name() == name)
                return true;
        }
        return false;
    }

    void RegisterIngredients(Registration items)
    {
        foreach(ingredient; m_ingredients)
        {
            string name = ingredient.Name();
            items.Register(name);
        }
    }

    void Print()
    {
        writeln("Allergens: ");
        foreach(allergen; m_allergens)
        {
            writeln("   ", allergen.Name(), " ");
        }
        writeln();

        writeln("Ingredients: ");
        foreach(ingr; m_ingredients)
        {
            writeln("   ", ingr.Name(), " ");
        }
        writeln();
    }
}

class Ingredients
{
    Ingredient[string] m_ingredients;

    Ingredient opIndex(string name)
    {
        Ingredient item;
        if ((name in m_ingredients) == null)
        {
            item = new Ingredient(name);
            m_ingredients[name] = item;
        }
        else
        {
            item = m_ingredients[name];
        }
        return item;
    }

    void PossiblyAffectedByAllergen(string ingredient_name, string allergen_name)
    {
        Ingredient ingredient = this[ingredient_name];
        ingredient.PossiblyAffectedByAllergen(allergen_name);
    }

    int UnaffectedIngredientsAppearHowManyTimes()
    {
        int c = 0;
        foreach(_, item; m_ingredients)
        {
            if (!item.ContainsAllergen())
            {
                c+=item.GetUsed();
            }
        }
        return c;
    }

    void Print()
    {
        writeln("List of Ingredients: ");
        foreach(_, item; m_ingredients)
        {
            item.Print();
        }
    }
}

class Allergens
{
    Allergen[string] m_allergens;
    string[] m_allergens_sorted;

    Allergen opIndex(string name)
    {
        Allergen item;
        if ((name in m_allergens) == null)
        {
            item = new Allergen(name);
            m_allergens[name] = item;
        }
        else
        {
            item = m_allergens[name];
        }
        return item;
    }

    void Affect(Food[] foods, Ingredients ingredients)
    {
        // Sort allergens by how many times they appear in food
        struct AllergenCount
        {
            int count;
            string name;
        }
        AllergenCount[] sorted;
        foreach(allergen_name, allergen; m_allergens)
        {
            int number_of_foods = 0;
            foreach(food; foods)
            {
                if (food.ContainsAllergen(allergen_name))
                {
                    number_of_foods += 1;
                }
            }
            AllergenCount ac = { count:number_of_foods, name:allergen_name };
            sorted ~= ac;
        }
        alias myComp = (x, y) => x.count < y.count;
        sorted.sort!(myComp);
        foreach(ac; sorted)
        {
            m_allergens_sorted ~= ac.name;
        }

        Registration registration = new Registration();
        foreach(allergen_name; m_allergens_sorted)
        {
            registration.Clear();

            int number_of_foods = 0;
            foreach(food; foods)
            {
                if (food.ContainsAllergen(allergen_name))
                {
                    number_of_foods += 1;
                    food.RegisterIngredients(registration);
                }
            }
            if (number_of_foods == 0)
            {
                writeln("error: allergen does not appear in any food ?");
            }

            // Every ingredient that has the same affecting-count for foods that it appeared in is possibly
            // containing the allergen.
            for (int i=0; i<registration.Count(); ++i)
            {
                int ingredient_count = registration.GetCount(i);
                string ingredient_name = registration.GetName(i);
                if (ingredient_count == number_of_foods)
                {
                    ingredients.PossiblyAffectedByAllergen(ingredient_name, allergen_name);
                }
            }
        }
    }

    void Print()
    {
        writeln("List of Allergens: ");
        foreach(_, allergen; m_allergens)
        {
            allergen.Print();
        }
    }
}

const int COLLECT_INGREDIENTS = 1;
const int COLLECT_ALLERGENS = 2;

/// 
void solve_21_1()
{
    Food[] foods;

    Ingredients ingredients = new Ingredients();
    Allergens allergens = new Allergens();

    auto parser = new InputParser();
    readFileLineByLine("input/input_21.text", (string line) {
        parser.reset(line);
        if (line.length == 0)
            return;

        Food food = new Food();

        auto parts = line.split(" ");
        int state = COLLECT_INGREDIENTS;

        foreach(part; parts)
        {
            part = stripRight(part, ")");
            part = stripRight(part, ",");

            if (part == "(contains")
            {
                state = COLLECT_ALLERGENS;
                continue;
            }

            if (state == COLLECT_INGREDIENTS)
            {
                Ingredient ingredient = ingredients[part];
                food.AddIngredient(ingredient);
            }
            else if (state == COLLECT_ALLERGENS)
            {
                Allergen allergen = allergens[part];
                food.AddAllergen(allergen);
            }
        }
        foods ~= food;
    });

    //foreach(index, food; foods)
    //{
    //    writeln("Index: ", index);
    //    food.Print();
    //}

    // For every food increase the use of every ingredient as well as mark every allergen on every ingredient
    allergens.Affect(foods, ingredients);

    allergens.Print();
    writeln();
    ingredients.Print();
    writeln();

    writeln("1: Unaffected ingredients appear ", ingredients.UnaffectedIngredientsAppearHowManyTimes(), " times");
    writeln();
}

/// 
void solve_21_2()
{
    Food[] foods;

    Ingredients ingredients = new Ingredients();
    Allergens allergens = new Allergens();

    auto parser = new InputParser();
    readFileLineByLine("input/input_21.text", (string line) {
        parser.reset(line);
        if (line.length == 0)
            return;

        Food food = new Food();

        auto parts = line.split(" ");
        int state = COLLECT_INGREDIENTS;

        foreach(part; parts)
        {
            part = stripRight(part, ")");
            part = stripRight(part, ",");

            if (part == "(contains")
            {
                state = COLLECT_ALLERGENS;
                continue;
            }

            if (state == COLLECT_INGREDIENTS)
            {
                Ingredient ingredient = ingredients[part];
                food.AddIngredient(ingredient);
            }
            else if (state == COLLECT_ALLERGENS)
            {
                Allergen allergen = allergens[part];
                food.AddAllergen(allergen);
            }
        }
        foods ~= food;
    });

    //foreach(index, food; foods)
    //{
    //    writeln("Index: ", index);
    //    food.Print();
    //}

    // For every food increase the use of every ingredient as well as mark every allergen on every ingredient
    allergens.Affect(foods, ingredients);

    //allergens.Print();
    //writeln();
    ingredients.Print();
    writeln();

    writeln("2: tmp,pdpgm,cdslv,zrvtg,ttkn,mkpmkx,vxzpfp,flnhl");

}
