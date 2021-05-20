// Name: Hien Dao The Nguyen
// ID: 103 152 195
// Date: April - 15 - 2021
// Purpose: Assignment 2 C++ DBS311NFF

#include <iostream>
#include <occi.h>
#include <vector>
#include <numeric>
#include "env.h"

using namespace std;
using oracle::occi::Environment;
using oracle::occi::Connection;
using oracle::occi::Statement;
using oracle::occi::SQLException;

struct ShoppingCart {
    int product_id;
    double price;
    int quantity;
};

// Print out the menu helper for the user to see what option they can select
void printMainMenu(const string &errorMessage = "") {
    cout << "******************** Main Menu ********************" << endl;
    cout << "1) Login" << endl;
    cout << "0) Exit" << endl;
    if (!errorMessage.empty())
        cout << errorMessage << " ";
    cout << "Enter an option (0-1): ";
}

// Checking if the option from the user is in the valid option range or not
int isValidOption(int start, int end, int option) {
    return option >= start && option <= end;
}

// The mainMenu() function returns an integer value which is the selected option by the user from the menu.
// Prompt the user to choose an option. If the user enters the wrong value, ask the user to enter an option again until the user enters a valid options
int mainMenu() {
    printMainMenu();
    int option;
    cin >> option;
    while (!isValidOption(0, 1, option)) {
        printMainMenu("You entered a wrong value.");
        cin >> option;
    }
    return option;
}

// This function receives an integer value as a customer ID and checks if the customer
// does exist in the database. This function returns 1 if the customer exists. If the customer
// does not exists, this function returns 0 and the main menu is displayed.
int customerLogin(Connection *connection, int customerID) {
    Statement *statement = nullptr;
    int found;
    try {
        statement = connection->createStatement();
        statement->setSQL("BEGIN find_customer(:1, :2); END;");
        statement->setInt(1, customerID);
        statement->registerOutParam(2, oracle::occi::Type::OCCIINT, sizeof(found));
        statement->executeQuery();
        found = statement->getInt(2);
        if (!found)
            cout << "The customer does not exist." << endl;
    } catch (SQLException &exception) {
        cout << exception.getErrorCode() << endl;
        cout << exception.getMessage() << endl;
    }
    connection->terminateStatement(statement);
    return found;
}

// This functions to check if the product ID exists. If the product exists, the function findProduct()
// returns the product’s price otherwise it return 0.
double findProduct(Connection *connection, int productID) {
    Statement *statement = nullptr;
    double listPrice;
    try {
        statement = connection->createStatement();
        statement->setSQL("BEGIN find_product(:1, :2); END;");
        statement->setInt(1, productID);
        statement->registerOutParam(2, oracle::occi::Type::OCCIDOUBLE, sizeof(listPrice));
        statement->executeQuery();
        listPrice = statement->getDouble(2);
    } catch (SQLException &exception) {
        cout << exception.getErrorCode() << endl;
        cout << exception.getMessage() << endl;
    }
    connection->terminateStatement(statement);
    return listPrice;
}

// This function allows the user to add up to 5 items to the cart
// For each time the user want to add an item, they will need to enter the product ID
// Then the findProduct() function will go to the database and search for the product
// If the product can be found, it will return the list price back, prompt for the quantity and add the product to the list for checkout later
// If the product can not be found then it shows a not found message and the user will need to try again
int addToCart(Connection *connection, vector<ShoppingCart> &cart) {
    cout << "-------------- Add Products to Cart --------------" << endl;
    int itemCounter = 0;
    while (itemCounter < 5) {
        cout << "Enter the product ID: ";
        int productID;
        cin >> productID;
        auto listPrice = findProduct(connection, productID);
        if (!listPrice) {
            cout << "The product does not exists. Try again..." << endl;
            continue;
        }
        cout << "Product Price: " << listPrice << endl;
        cout << "Enter the product Quantity: ";
        int quantity;
        cin >> quantity;
        cart.emplace_back(ShoppingCart{productID, listPrice, quantity});
        if (++itemCounter < 5) {
            cout << "Enter 1 to add more products or 0 to checkout: ";
            int option;
            cin >> option;
            if (option) continue;
            else break;
        }
    }
    return cart.size();
}

// This function receives an array of type ShoppingCart and the number of ordered items
// (products). It display the product ID, price, and quantity for products stored in the cart
// array.
// After displaying the products’ information (product ID, price, and quantity), display the
// total order amount.
void displayProducts(const vector<ShoppingCart> &cart) {
    cout << "------- Ordered Products ---------" << endl;
    int itemIndex = 0;
    for (auto &item : cart) {
        cout << "---Item " << ++itemIndex << endl;
        cout << "Product ID: " << item.product_id << endl;
        cout << "Price: " << item.price << endl;
        cout << "Quantity: " << item.quantity << endl;
    }
    cout << "----------------------------------" << endl;
    auto total = accumulate(cart.begin(), cart.end(), (double) 0, [&](double price, const ShoppingCart &item) {
        return item.price * item.quantity + price;
    });
    cout << "Total: " << total << endl;
}


// This function will insert all items in the cart to the database
// First it will ask the user to see if they want to process to checkout
// If the user select "no" it will cancel the operation
// If the user enters “Y/y”, the Oracle stored procedure add_order() is called. This procedure
// will add a row in the orders table with a new order ID
// This stored procedure returns an order ID, which will be used to store ordered items in the
// table order_items.
// Next the program will go through all products in the array cart, call the stored procedure add_order_item() for each item to save it to the database
int checkout(Connection *connection, vector<ShoppingCart> &cart, int customerID) {
    Statement *statement = nullptr;
    int result = 0;
    try {
        statement = connection->createStatement();
        statement->setAutoCommit(true);
        cout << "Would you like to checkout? (Y/y or N/n) ";
        string option;
        cin >> option;
        while (option != "y" && option != "Y" && option != "n" && option != "N") {
            cout << "Wrong input. Try again..." << endl;
            cout << "Would you like to checkout? (Y/y or N/n) ";
            cin >> option;
        }

        if (option == "Y" || option == "y") {
            int nextOrderID;
            statement->setSQL("BEGIN add_order(:1, :2); END;");
            statement->setUInt(1, customerID);
            statement->registerOutParam(2, oracle::occi::Type::OCCIINT, sizeof(nextOrderID));
            statement->executeQuery();
            nextOrderID = statement->getInt(2);

            unsigned int itemIndex = 0;
            for (auto &item : cart) {
                statement->setSQL("BEGIN add_order_item(:1, :2, :3, :4, :5); END;");
                statement->setUInt(1, nextOrderID);
                statement->setUInt(2, ++itemIndex);
                statement->setUInt(3, item.product_id);
                statement->setUInt(4, item.quantity);
                statement->setDouble(5, item.price);
                statement->executeQuery();
            }
            statement->setAutoCommit(false);
            result = 1;
        }
    } catch (SQLException &exception) {
        statement->setAutoCommit(false);
        cout << exception.getErrorCode() << endl;
        cout << exception.getMessage() << endl;
    }
    connection->terminateStatement(statement);
    return result;
}

int main() {
    auto environment = Environment::createEnvironment(Environment::DEFAULT);
    auto connection = environment->createConnection(env::username, env::password, env::server);

    int option = mainMenu();
    while (option != 0) {
        int customerID;
        cout << "Enter the customer ID: ";
        cin >> customerID;
        cin.clear();
        cin.ignore(2000, '\n');

        if (customerLogin(connection, customerID)) {
            vector<ShoppingCart> cart;
            addToCart(connection, ref(cart));
            displayProducts(ref(cart));

            if (checkout(connection, ref(cart), customerID)) {
                cout << "The order is successfully completed." << endl;
            } else {
                cout << "The order is cancelled." << endl;
            }
        }

        option = mainMenu();
    }
    cout << "Good bye!..." << endl;

    environment->terminateConnection(connection);
    Environment::terminateEnvironment(environment);
    return 0;
}