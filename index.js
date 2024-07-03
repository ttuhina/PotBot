const restify = require('restify');
const { BotFrameworkAdapter, ActivityHandler } = require('botbuilder');
const axios = require('axios');

// Create instance of BotFrameworkAdapter
const adapter = new BotFrameworkAdapter({
  appId: process.env.MicrosoftAppId || '',
  appPassword: process.env.MicrosoftAppPassword || ''
});

class MyBot extends ActivityHandler {
  constructor() {
    super();
    this.knownRestaurants = [];
    this.loadRestaurantNames();
    this.currentOrder = null;
    this.currentReservation = null;

    this.onMembersAdded(async (context, next) => {
      const membersAdded = context.activity.membersAdded;
      for (const member of membersAdded) {
        if (member.id !== context.activity.recipient.id) {
          await context.sendActivity('Welcome to the restaurant manager! I can help you find restaurants, make reservations, or place orders. How can I assist you today?');
        }
      }
      await next();
    });
    
    this.onMessage(async (context, next) => {
      const text = context.activity.text.toLowerCase().trim();

      if (text.startsWith('order')) {
        await this.handleOrder(context, text);
      } else if (this.currentOrder && !this.currentOrder.orderType) {
        await this.handleOrderType(context, text);
      } else if (this.currentOrder && !this.currentOrder.items.length) {
        await this.processOrderItems(context, text);
      } else if (this.currentOrder && this.currentOrder.items.length) {
        await this.confirmOrder(context, text);
      } else if (this.currentReservation) {
  await this.processReservationDetails(context, text);
} else if (text.includes('reserve') || text.includes('reservation')) {
        const restaurantName = this.findRestaurantName(text);
        if (restaurantName) {
          await this.handleReservation(context, restaurantName);
        } else {
          await context.sendActivity("I'm sorry, I didn't catch the restaurant name. Could you please specify the restaurant name again?");
        }
      } else {
        const restaurantName = this.findRestaurantName(text);
        if (restaurantName) {
          await this.handleRestaurantQuery(context, text, restaurantName);
        } else {
          await this.processCriteria(context, text);
        }
      }

      await next();
    });
  }
  async handleOrder(context, text) {
    const restaurantName = text.replace(/^order\s*/i, '').trim();
    
    if (!restaurantName) {
      await context.sendActivity("Please provide a restaurant name. For example: 'order Pizza Palace'");
      return;
    }
  
    const lowerCaseRestaurantName = restaurantName.toLowerCase();
    
    const matchedRestaurant = this.knownRestaurants.find(name => 
      name.toLowerCase().includes(lowerCaseRestaurantName) || 
      lowerCaseRestaurantName.includes(name.toLowerCase())
    );
    
    if (matchedRestaurant) {
      this.currentOrder = { restaurantName: matchedRestaurant, items: [] };
      await context.sendActivity(`Great! Would you like to order for delivery or pickup from ${matchedRestaurant}? (Please respond with 'Delivery' or 'Pickup')`);
    } else {
      await context.sendActivity(`I'm sorry, I couldn't find a restaurant matching "${restaurantName}". Please check the name and try again. Here are the available restaurants:
      ${this.knownRestaurants.join(', ')}`);
    }
  }
  
// Handles the type of order - Delivery or Pickup
async handleOrderType(context, text) {
  const orderType = text.trim().toLowerCase();
  if (orderType !== 'delivery' && orderType !== 'pickup') {
      await context.sendActivity("Please specify either 'Delivery' or 'Pickup'.");
      return;
  }

  // Ensure that currentOrder is initialized
  if (!this.currentOrder) {
      this.currentOrder = {};
  }

  this.currentOrder.orderType = orderType;

  // Use backticks for template literals and proper concatenation
  await context.sendActivity(`Great! What would you like to order from ${this.currentOrder.restaurantName}? Please list your items separated by commas. For example: "Chicken Tikka Masala, Naan Bread, Mango Lassi"`);
}

// Load known restaurant names into an array
loadRestaurantNames() {
  this.knownRestaurants = [
    'Golden Dragon', 'Red Lantern', 'Dragon’s Breath', 'Casa Bonita', 'El Toro',
    'Pablo’s Cantina', 'Bangkok Street', 'Lotus Thai', 'Siam Sizzler', 'Maharaja’s Delight',
    'Spice Route', 'Nawab’s Court', 'Pasta Fiesta', 'Bella Italia', 'Tuscan Table',
    'Sakura Sushi', 'Tokyo Dine', 'Zen Garden', 'Olive Tree', 'The Greek House',
    'Byzantine', 'Le Bistro', 'Café Paris', 'Château Noir', 'Burger Joint',
    'Diner Dash', 'Steakhouse 55'
];
}

// Find a restaurant name in the input text
findRestaurantName(input) {
  for (const name of this.knownRestaurants) {
      // Ensure input is in lower case for comparison
      if (input.toLowerCase().includes(name.toLowerCase())) {
          return name;
      }
  }
  return null;
}

// Handle queries about the restaurant
async handleRestaurantQuery(context, text, restaurantName) {
  const lowerText = text.toLowerCase();
  if (lowerText.includes('description')) {
      await this.sendRestaurantDescription(context, restaurantName);
  } else if (lowerText.includes('menu')) {
      await this.sendRestaurantMenu(context, restaurantName);
  } else if (lowerText.includes('positive review')) {
      await this.sendPositiveReviews(context, restaurantName);
  } else if (lowerText.includes('negative review')) {
      await this.sendNegativeReviews(context, restaurantName);
  } else {
      await context.sendActivity(`What would you like to know about ${restaurantName}? You can ask for the description, menu, positive reviews, or negative reviews.`);
  }
}

// Process the items the user wants to order
async processOrderItems(context, text) {
  const items = text.split(',').map(item => item.trim()).filter(item => item !== '');
  
  if (items.length === 0) {
      await context.sendActivity("Your order seems to be empty. Please provide at least one item.");
      return;
  }

  // Ensure that currentOrder is initialized
  if (!this.currentOrder) {
      this.currentOrder = {};
  }

  try {
      const restaurantIdResponse = await axios.post('http://localhost:3000/api/id', { restaurant_name: this.currentOrder.restaurantName });
      const restaurantId = restaurantIdResponse.data.id;

      const menuItemsResponse = await axios.post('http://localhost:3000/api/menu', { restaurant_id: restaurantId, item: items });
      const menuItems = menuItemsResponse.data;

      if (menuItems.length === 0) {
          throw new Error("No menu items found for your order.");
      }

      this.currentOrder.items = menuItems;
      this.currentOrder.restaurantId = restaurantId;

      await this.displayOrderSummary(context);
  } catch (error) {
      console.error('Error processing order:', error);
      let errorMessage = 'Sorry, there was an error processing your order. ';
      if (error.response) {
          errorMessage += `Server responded with: ${error.response.status} - ${error.response.data}`;
      } else if (error.request) {
          errorMessage += 'No response received from the server. Please check your internet connection.';
      } else {
          errorMessage += error.message;
      }
      errorMessage += '\nPlease try again by saying "order [restaurant name]".';
      await context.sendActivity(errorMessage);
      this.currentOrder = null; // Reset the current order on error
  }
}

// Display the order summary to the user
async displayOrderSummary(context) {
  let totalPrice = 0;
  let orderSummary = 'Here\'s a summary of your order:\n';

  for (const item of this.currentOrder.items) {
      // Ensure item, name, and price are defined before accessing
      if (item && item.name && item.price) {
          orderSummary += `${item.name}: ₹${item.price}\n`;
          totalPrice += item.price;
      }
  }

  orderSummary += `\nTotal price: ₹${totalPrice.toFixed(2)}`;
  orderSummary += '\n\nTo add an item, say "add {item name}". To remove an item, say "remove {item name}".';
  orderSummary += '\nTo confirm the order, say "Yes". To cancel, say "No".';

  this.currentOrder.totalPrice = totalPrice;

  await context.sendActivity(orderSummary);
}

// Confirm the order, handle adding/removing items or finalizing the order
async confirmOrder(context, text) {
  const lowerText = text.toLowerCase().trim();

  if (lowerText.startsWith('add ')) {
      await this.addItem(context, lowerText.substring(4));
  } else if (lowerText.startsWith('remove ')) {
      await this.removeItem(context, lowerText.substring(7));
  } else if (lowerText === 'yes' || lowerText === 'no') {
      await this.finalizeOrder(context, lowerText);
  } else {
      await context.sendActivity('Please respond with "Yes" to confirm, "No" to cancel, "add {item}" to add an item, or "remove {item}" to remove an item.');
  }
}

// Add an item to the order
async addItem(context, itemName) {
  try {
      const menuItemResponse = await axios.post('http://localhost:3000/api/menu', { 
          restaurant_id: this.currentOrder.restaurantId, 
          item: [itemName] 
      });
      const newItem = menuItemResponse.data[0];

      if (newItem) {
          this.currentOrder.items.push(newItem);
          await context.sendActivity(`Added ${newItem.name} to your order.`);
      } else {
          await context.sendActivity(`Sorry, I couldn't find "${itemName}" on the menu.`);
      }

      await this.displayOrderSummary(context);
  } catch (error) {
      console.error('Error adding item:', error);
      await context.sendActivity('Sorry, there was an error adding the item to your order.');
  }
}

// Remove an item from the order
async removeItem(context, itemName) {
  const index = this.currentOrder.items.findIndex(item => item.name && item.name.toLowerCase() === itemName.toLowerCase());
  if (index !== -1) {
      const removedItem = this.currentOrder.items.splice(index, 1)[0];
      await context.sendActivity(`Removed ${removedItem.name} from your order.`);
  } else {
      await context.sendActivity(`Sorry, I couldn't find "${itemName}" in your order.`);
  }

  await this.displayOrderSummary(context);
}

// Finalize the order based on user's confirmation
async finalizeOrder(context, confirmation) {
  if (confirmation === 'yes') {
      try {
          const orderData = {
              restaurant_id: this.currentOrder.restaurantId,
              username: context.activity.from.name,
              order_type: this.currentOrder.orderType,
              order_details: JSON.stringify(this.currentOrder.items),
              total_price: this.currentOrder.totalPrice
          };

          const response = await axios.post('http://localhost:3000/api/orders', orderData);
          await context.sendActivity(`Your order has been placed successfully for ${this.currentOrder.orderType}! Order ID: ${response.data.order_id}
          
If you'd like to place another order, just say "order [restaurant name]".`);
      } catch (error) {
          console.error('Error confirming order:', error);
          let errorMessage = 'Sorry, there was an error placing your order. ';
          if (error.response) {
              errorMessage += `Server responded with: ${error.response.status} - ${error.response.data}`;
          } else if (error.request) {
              errorMessage += 'No response received from the server. Please check your internet connection.';
          } else {
              errorMessage += error.message;
          }
          errorMessage += '\nPlease try again by saying "order [restaurant name]".';
          await context.sendActivity(errorMessage);
      }
  } else {
      await context.sendActivity('Order cancelled. If you\'d like to start over, just say "order [restaurant name]". Is there anything else I can help you with?');
  }
  this.currentOrder = null; // Reset current order after finalization or cancellation
}

  async handleReservation(context, restaurantName) {
    this.currentReservation = { restaurantName };
    await context.sendActivity(`Great! You want to make a reservation at ${restaurantName}. Let's get started.`);
    await context.sendActivity('Please provide the following details in order:\n' +
      '1. Name\n' +
      '2. Date (YYYY-MM-DD)\n' +
      '3. Time (HH:MM)\n' +
      '4. Special requests (if any, otherwise type "None")\n\n' +
      'Example: John Doe, 2024-06-21, 19:00, Vegetarian preferences');
  }

  async processReservationDetails(context, text) {
  console.log('Received reservation details:', text);
  const details = text.split(',').map(item => item.trim());
  console.log('Split details:', details);

  if (details.length !== 4) {
    console.log('Invalid number of details:', details.length);
    await context.sendActivity('Invalid input format. Please provide details in the correct format.');
    return;
  }

  const [userName, reservationDate, reservationTime, specialRequests] = details;

  // Validate date and time format
  const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
  const timeRegex = /^([01]\d|2[0-3]):([0-5]\d)$/;
  
  if (!dateRegex.test(reservationDate)) {
    console.log('Invalid date format:', reservationDate);
    await context.sendActivity('Invalid date format. Please use YYYY-MM-DD.');
    return;
  }

  if (!timeRegex.test(reservationTime)) {
    console.log('Invalid time format:', reservationTime);
    await context.sendActivity('Invalid time format. Please use HH:MM.');
    return;
  }

  this.currentReservation = {
    ...this.currentReservation,
    userName,
    reservationDate,
    reservationTime,
    specialRequests
  };

  console.log('Current reservation:', this.currentReservation);

  await context.sendActivity(
    `Let me confirm your reservation details:\n` +
    `Restaurant: ${this.currentReservation.restaurantName}\n` +
    `Name: ${this.currentReservation.userName}\n` +
    `Date: ${this.currentReservation.reservationDate}\n` +
    `Time: ${this.currentReservation.reservationTime}\n` +
    `Special Requests: ${this.currentReservation.specialRequests}\n\n` +
    `Is this correct? (Yes/No)`
  );
}

  async confirmReservation(context, confirmation) {
    if (confirmation.toLowerCase() === 'yes') {
      try {
        const response = await axios.post('http://localhost:3000/api/reservations', this.currentReservation);
        await context.sendActivity('Your reservation has been made successfully!');
      } catch (error) {
        console.error('Error making reservation:', error);
        await context.sendActivity('Sorry, there was an error making your reservation.');
      }
    } else {
      await context.sendActivity('Reservation cancelled. Is there anything else I can help you with?');
    }
    this.currentReservation = null;
  }

  async sendRestaurantDescription(context, restaurantName) {
    try {
      const response = await axios.get(`http://localhost:3000/api/restaurant/description?name=${encodeURIComponent(restaurantName)}`);
      const description = response.data.description;
      await context.sendActivity(description ? `Description for ${restaurantName}: ${description}` : `Sorry, I couldn't find the description for ${restaurantName}.`);
    } catch (error) {
      console.error('Error fetching restaurant description:', error);
      await context.sendActivity(`Sorry, I couldn't find the description for ${restaurantName}.`);
    }
  }

  async sendRestaurantMenu(context, restaurantName) {
    try {
      const response = await axios.get(`http://localhost:3000/api/restaurant/menu?name=${encodeURIComponent(restaurantName)}`);
      const menuImageUrl = response.data.menu;
      if (menuImageUrl) {
        await context.sendActivity({
          type: 'message',
          text: `Here is the menu for ${restaurantName}:`,
          attachments: [{ contentType: 'image/jpeg', contentUrl: menuImageUrl, name: 'Menu' }]
        });
      } else {
        await context.sendActivity(`Sorry, I couldn't find the menu for ${restaurantName}.`);
      }
    }  catch (error) {
      console.error('Error fetching restaurant menu image:', error);
      if (error.response) {
        if (error.response.status === 404) {
          await context.sendActivity(`Sorry, I couldn't find a restaurant named ${restaurantName}.`);
        } else {
          await context.sendActivity(`Sorry, there was an error fetching the menu for ${restaurantName}. Please try again later.`);
        }
      } else {
        await context.sendActivity(`Sorry, there was a network error. Please try again later.`);
      }
    }
  }

  async sendPositiveReviews(context, restaurantName) {
    try {
      const response = await axios.get(`http://localhost:3000/api/reviews/positive?restaurantName=${encodeURIComponent(restaurantName)}`);
      const { reviews } = response.data;
      if (reviews && reviews.length > 0) {
        let message = `Positive reviews for ${restaurantName}:`;
        reviews.forEach((review, index) => {
          message += `\n${index + 1}. ${review.username} said - ${review.review}`;
        });
        await context.sendActivity(message);
      } else {
        await context.sendActivity(`No positive reviews found for ${restaurantName}.`);
      }
    } catch (error) {
      console.error('Error fetching positive reviews:', error);
      await context.sendActivity(`Sorry, I couldn't fetch positive reviews for ${restaurantName}.`);
    }
  }
  
  async sendNegativeReviews(context, restaurantName) {
    try {
      const response = await axios.get(`http://localhost:3000/api/reviews/negative?restaurantName=${encodeURIComponent(restaurantName)}`);
      const { reviews } = response.data;
      if (reviews && reviews.length > 0) {
        let message = `Negative reviews for ${restaurantName}:`;
        reviews.forEach((review, index) => {
          message += `\n${index + 1}. ${review.username} said that ${review.review}`;
        });
        await context.sendActivity(message);
      } else {
        await context.sendActivity(`No negative reviews found for ${restaurantName}.`);
      }
    } catch (error) {
      console.error('Error fetching negative reviews:', error);
      await context.sendActivity(`Sorry, I couldn't fetch negative reviews for ${restaurantName}.`);
    }
  }
  
  async processCriteria(context, text) {
    const cuisine = text.match(/cuisine:?\s*(\w+)/)?.[1] || '';
    const location = text.match(/location:?\s*(\w+)/)?.[1] || '';
    let price = text.match(/price:?\s*([\w\s]+)/)?.[1]?.trim() || '';

    const priceMapping = {
      affordable: 'affordable', inexpensive: 'affordable', cheap: 'affordable', low: 'affordable', $: 'affordable',
      moderate: 'moderate', average: 'moderate', normal: 'moderate', $$: 'moderate',
      expensive: 'expensive', pricey: 'expensive', high: 'expensive', $$$: 'expensive'
    };
    price = priceMapping[price] || price;

    if (cuisine || location || price) {
      try {
        const response = await axios.get(`http://localhost:3000/api/restaurants?cuisine=${cuisine}&location=${location}&price=${price}`);
        const restaurants = response.data;
        if (restaurants.length > 0) {
          let message = 'Here are some restaurants that match your criteria:';
          restaurants.forEach((restaurant, index) => {
            message += `\n${index + 1}. ${restaurant.name}`;
          });
          message += '\n\nYou may ask for a menu, description, positive reviews, or negative reviews by writing those terms accompanied by the restaurant name! Let me know when you\'ve selected a restaurant to visit or order from.';
          await context.sendActivity(message);
        } else {
          await context.sendActivity('Sorry, no restaurants found matching your criteria.');
        }
      } catch (error) {
        console.error('Error fetching restaurants:', error);
        await context.sendActivity('Sorry, there was an error fetching restaurants.');
      }
    } else {
      await context.sendActivity('Please provide at least one criteria: Cuisine, Location, or Price.');
    }
  }
}

module.exports.MyBot = MyBot;

// Initialize the bot
const bot = new MyBot();

// Setup restify server
const server = restify.createServer();
server.use(restify.plugins.bodyParser());

// Listen for incoming requests
server.post('/api/messages', async (req, res) => {
  try {
    await adapter.processActivity(req, res, async (context) => {
      // Route to main dialog.
      await bot.run(context);
    });
  } catch (error) {
    console.error('Error processing request:', error);
    res.status(500).send('Internal Server Error');
  }
});

// Start the server
server.listen(process.env.PORT || 3978, () => {
  console.log(`Server running at http://localhost:${process.env.PORT || 3978}`);
});