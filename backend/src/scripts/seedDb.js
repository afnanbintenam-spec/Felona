require('dotenv').config({ path: require('path').resolve(__dirname, '../../.env') });
const { sequelize, User, Listing, Pickup, EcoActivity } = require('../models');

async function seed() {
  try {
    await sequelize.authenticate();
    await sequelize.sync({ force: true }); // WARNING: drops all tables
    console.log('Tables created.');

    // Create users
    const afnan = await User.create({
      full_name: 'Afnan',
      email: 'afnan@felona.app',
      password: 'password123',
      role: 'normal_user',
      eco_points: 1250,
      eco_level: 'Forest',
      current_streak: 7,
      longest_streak: 14,
    });

    const buyer = await User.create({
      full_name: 'Sara Ahmed',
      email: 'sara@example.com',
      password: 'password123',
      role: 'buyer',
      eco_points: 320,
      eco_level: 'Sprout',
    });

    const collector = await User.create({
      full_name: 'Rahim Khan',
      email: 'rahim@example.com',
      password: 'password123',
      role: 'collector',
      eco_points: 890,
      eco_level: 'Tree',
    });

    console.log('Users created.');

    // Create listings
    await Listing.bulkCreate([
      { user_id: afnan.id, title: 'Vintage Wooden Chair', description: 'Beautiful handcrafted chair, needs a new home. Minor scratches.', price: 25.00, category: 'furniture', condition: 'good', status: 'active' },
      { user_id: afnan.id, title: 'Old Laptop (Working)', description: 'Dell Inspiron 2019, works fine, battery needs replacement.', price: 80.00, category: 'electronics', condition: 'fair', status: 'active' },
      { user_id: afnan.id, title: 'Glass Jars Collection', description: '12 mason jars, perfect for storage or crafts.', price: 8.00, category: 'glass', condition: 'like_new', status: 'active' },
      { user_id: buyer.id, title: 'Cardboard Boxes (50)', description: 'Moving boxes in great condition. Various sizes.', price: 15.00, category: 'paper', condition: 'good', status: 'active' },
      { user_id: afnan.id, title: 'Metal Scrap Bundle', description: 'Assorted metal pieces from renovation. ~5kg total.', price: 12.00, category: 'metal', condition: 'fair', status: 'active' },
    ]);
    console.log('Listings created.');

    // Create pickups
    await Pickup.bulkCreate([
      { user_id: afnan.id, collector_id: collector.id, waste_category: 'plastic', estimated_weight: 3.5, address: '123 Green Street, Dhaka', status: 'recycled', eco_points_earned: 35, weight_saved: 3.5, completed_at: new Date(Date.now() - 86400000) },
      { user_id: afnan.id, waste_category: 'paper', estimated_weight: 2.0, address: '123 Green Street, Dhaka', status: 'requested', scheduled_date: new Date(Date.now() + 86400000) },
      { user_id: afnan.id, collector_id: collector.id, waste_category: 'electronics', estimated_weight: 1.5, address: '123 Green Street, Dhaka', status: 'accepted' },
    ]);
    console.log('Pickups created.');

    // Create eco activities
    await EcoActivity.bulkCreate([
      { user_id: afnan.id, type: 'signup_bonus', points: 50, description: 'Welcome to FeloNa! 🌱' },
      { user_id: afnan.id, type: 'pickup_completed', points: 35, description: '🌍 3.5kg plastic saved from landfill!' },
      { user_id: afnan.id, type: 'item_listed', points: 15, description: 'Listed "Vintage Wooden Chair" — giving it a second life! 💚' },
      { user_id: afnan.id, type: 'item_listed', points: 15, description: 'Listed "Old Laptop" — giving it a second life! 💚' },
      { user_id: afnan.id, type: 'scan_completed', points: 10, description: '📸 Scanned plastic bottle — identified correctly!' },
    ]);
    console.log('Eco activities created.');

    console.log('\n✅ Database seeded successfully!');
    console.log('\n📋 Test accounts:');
    console.log('   Normal User: afnan@felona.app / password123');
    console.log('   Buyer: sara@example.com / password123');
    console.log('   Collector: rahim@example.com / password123');

    process.exit(0);
  } catch (error) {
    console.error('❌ Seed failed:', error.message);
    process.exit(1);
  }
}

seed();
