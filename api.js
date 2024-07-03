const express = require('express');
const mysql = require('mysql');
const bodyParser = require('body-parser');

const app = express();

// Middleware to parse JSON body
app.use(express.json());

// MySQL Connection
const db = mysql.createConnection({
    host: 'localhost',
    user: 'root',
    password: '', // Add your MySQL password here
    database: 'restaurant_bot'
});

// Connect to MySQL
db.connect((err) => {
    if (err) {
        console.error('Error connecting to MySQL:', err);
        // Handle error gracefully, maybe retry connection or log it
    } else {
        console.log('MySQL Connected');
    }
});

// Search restaurants by cuisine, price, and location
app.get('/api/restaurants', (req, res) => {
    const { cuisine, price, location } = req.query;

    let query = 'SELECT r.id, r.name, AVG(re.rating) AS avg_rating ' +
    'FROM restaurants r ' +
    'LEFT JOIN reviews re ON r.id = re.restaurant_id ' +
    'WHERE 1=1 ';

    const queryParams = [];

    if (cuisine) {
      query += 'AND r.cuisine LIKE ? ';
      queryParams.push(`%${cuisine}%`);
    }

    if (price) {
      query += 'AND r.price = ? ';
      queryParams.push(price);
    }

    if (location) {
      query += 'AND r.location LIKE ? ';
      queryParams.push(`%${location}%`);
    }

    query += 'GROUP BY r.id, r.name';

    db.query(query, queryParams, (err, results) => {
      if (err) {
        console.error('Error executing query:', err);
        return res.status(500).json({ error: 'Error executing query' });
      }

      if (results.length === 0) {
        return res.status(404).json({ error: 'Restaurant not found' });
      }

      // Format the response to include avg rating
      const formattedResults = results.map(result => ({
        name: `${result.name} (${result.avg_rating ? result.avg_rating.toFixed(1) : 'N/A'})`
      }));

      res.json(formattedResults);
    });
});

// Get specific restaurant's description by name
app.get('/api/restaurant/description', (req, res) => {
    const { name } = req.query;

    if (!name) {
        return res.status(400).json({ error: 'Restaurant name is required' });
    }

    const query = 'SELECT description FROM restaurants WHERE name = ?';
    db.query(query, [name], (err, results) => {
        if (err) {
            console.error('Error executing query:', err);
            return res.status(500).json({ error: 'Error executing query' });
        }

        if (results.length === 0) {
            return res.status(404).json({ error: 'Restaurant not found' });
        }

        res.json({ description: results[0].description });
    });
});

// Get specific restaurant's menu image by name
app.get('/api/restaurant/menu', (req, res) => {
    const { name } = req.query;

    if (!name) {
        return res.status(400).json({ error: 'Restaurant name is required' });
    }

    const query = 'SELECT menu FROM restaurants WHERE name = ?';
    db.query(query, [name], (err, results) => {
        if (err) {
            console.error('Error executing query:', err);
            return res.status(500).json({ error: 'Error executing query' });
        }

        if (results.length === 0) {
            return res.status(404).json({ error: 'Restaurant not found' });
        }

        const menuImageUrl = results[0].menu;

        // Log the fetched menu URL for debugging
        console.log(`Fetched menu URL for restaurant "${name}":`, menuImageUrl);

        if (!menuImageUrl) {
            return res.status(404).json({ error: 'Menu not found for this restaurant' });
        }

        // Check if the menu URL is a valid URL (optional validation)
        const urlPattern = /^(https?|ftp):\/\/[^\s/$.?#].[^\s]*$/i;
        if (!urlPattern.test(menuImageUrl)) {
            return res.status(400).json({ error: 'Invalid menu URL format' });
        }

        res.json({ menu: menuImageUrl });
    });
});

// Get positive reviews for a restaurant
app.get('/api/reviews/positive', (req, res) => {
    const { restaurantName } = req.query;

    if (!restaurantName) {
        return res.status(400).json({ error: 'Restaurant name is required' });
    }

    // First, fetch restaurant ID from the restaurants table
    const query1 = 'SELECT id FROM restaurants WHERE name = ?';
    db.query(query1, [restaurantName], (err, results) => {
        if (err) {
            console.error('Error fetching restaurant ID:', err);
            return res.status(500).json({ error: 'Error fetching restaurant ID' });
        }

        if (results.length === 0) {
            return res.status(404).json({ error: 'Restaurant not found' });
        }

        const restaurantId = results[0].id;

        // Fetch positive reviews (rating 3, 4, 5) for the restaurant
        const query2 = 'SELECT username, review FROM reviews WHERE restaurant_id = ? AND rating IN (3, 4, 5)';
        db.query(query2, [restaurantId], (err, reviews) => {
            if (err) {
                console.error('Error fetching positive reviews:', err);
                return res.status(500).json({ error: 'Error fetching positive reviews' });
            }

            if (reviews.length === 0) {
                return res.status(404).json({ error: 'No positive reviews found for this restaurant' });
            }

            res.json({ restaurantName, reviews });
        });
    });
});

// Get negative reviews for a restaurant
app.get('/api/reviews/negative', (req, res) => {
    const { restaurantName } = req.query;

    if (!restaurantName) {
        return res.status(400).json({ error: 'Restaurant name is required' });
    }

    // First, fetch restaurant ID from the restaurants table
    const query1 = 'SELECT id FROM restaurants WHERE name = ?';
    db.query(query1, [restaurantName], (err, results) => {
        if (err) {
            console.error('Error fetching restaurant ID:', err);
            return res.status(500).json({ error: 'Error fetching restaurant ID' });
        }

        if (results.length === 0) {
            return res.status(404).json({ error: 'Restaurant not found' });
        }

        const restaurantId = results[0].id;

        // Fetch negative reviews (rating 1, 2) for the restaurant
        const query2 = 'SELECT username, review FROM reviews WHERE restaurant_id = ? AND rating IN (1, 2)';
        db.query(query2, [restaurantId], (err, reviews) => {
            if (err) {
                console.error('Error fetching negative reviews:', err);
                return res.status(500).json({ error: 'Error fetching negative reviews' });
            }

            if (reviews.length === 0) {
                return res.status(404).json({ error: 'No negative reviews found for this restaurant' });
            }

            res.json({ restaurantName, reviews });
        });
    });
});


// Create a reservation
app.post('/api/reservations', (req, res) => {
    console.log('Received reservation request:', req.body);
    const { restaurantName, userName, reservationDate, reservationTime, specialRequests } = req.body;
  
    // Validate required fields
    if (!restaurantName || !userName || !reservationDate || !reservationTime) {
      console.log('Missing required fields');
      return res.status(400).json({ error: 'All fields except special requests are required' });
    }
  
    // Validate date and time format
    const dateRegex = /^\d{4}-\d{2}-\d{2}$/;
    const timeRegex = /^([01]\d|2[0-3]):([0-5]\d)$/;
    if (!dateRegex.test(reservationDate) || !timeRegex.test(reservationTime)) {
      console.log('Invalid date or time format:', { reservationDate, reservationTime });
      return res.status(400).json({ error: 'Invalid date or time format' });
    }
  
    // Rest of your code...
    // Remember to log errors in your database queries as well
  });
// Endpoint to get restaurant ID by name
app.post('/api/id', (req, res) => {
    const { restaurant_name } = req.body;
    if (!restaurant_name) {
        return res.status(400).json({ error: 'Restaurant name is required' });
    }
    const query = `SELECT id FROM restaurants WHERE name = ?`;
    db.query(query, [restaurant_name], (err, results) => {
        if (err) {
            console.error('Database error:', err);
            return res.status(500).json({ error: 'Internal server error' });
        }
        if (results.length === 0) {
            return res.status(404).json({ error: 'Restaurant not found' });
        }
        res.json({ id: results[0].id });
    });
});

app.post('/api/menus', (req, res) => {
    const { restaurant_id, item } = req.body;
    if (!restaurant_id || !Array.isArray(item) || item.length === 0) {
        return res.status(400).json({ error: 'Invalid input' });
    }
    const placeholders = item.map(() => '?').join(',');
    const query = `
        SELECT item, price 
        FROM menus 
        WHERE restaurant_id = ? AND item IN (${placeholders})
    `;
    db.query(query, [restaurant_id, ...item], (err, results) => {
        if (err) {
            console.error('Database error:', err);
            return res.status(500).json({ error: 'Internal server error' });
        }
        res.json(results);
    });
});

app.post('/api/orders', (req, res) => {
    const { restaurant_id, username, order_type, order_details, total_price } = req.body;
    if (!restaurant_id || !user_name || !order_type || !order_details || total_price === undefined) {
        return res.status(400).json({ error: 'Missing required fields' });
    }
    const query = `
        INSERT INTO orders (restaurant_id, username, order_type, order_details, total_price)
        VALUES (?, ?, ?, ?, ?)
    `;
    db.query(query, [restaurant_id, username, order_type, order_details, total_price], (err, result) => {
        if (err) {
            console.error('Database error:', err);
            return res.status(500).json({ error: 'Internal server error' });
        }
        res.status(201).json({ message: 'Order created successfully', order_id: result.insertId });
    });
});

// Error handling middleware
app.use((err, req, res, next) => {
    console.error(err.stack);
    res.status(500).send('Something broke!');
});

app.listen(3000, () => {
    console.log('Server is running on port 3000');
});