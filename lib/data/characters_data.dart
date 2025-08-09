import 'character.dart';

final List<Character> characters = [
  Character(
    id: '1',
    name: 'Emma',
    description:
        'Love hiking, yoga, and exploring new coffee shops. Looking for someone who shares my passion for adventure!',
    imageUrl:
        'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=400',
    age: 28,
    location: 'New York, NY',
    interests: ['Hiking', 'Yoga', 'Coffee', 'Photography', 'Travel'],
    distanceKm: 2.5,
    lastActive: DateTime.now().subtract(const Duration(minutes: 30)),
    profession: 'Marketing Manager',
    isBookmarked: true, // Pre-bookmark for demo
  ),
  Character(
    id: '2',
    name: 'James',
    description:
        'Software engineer who loves cooking, reading sci-fi novels, and weekend getaways. Let\'s build something together!',
    imageUrl:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400',
    age: 32,
    location: 'San Francisco, CA',
    interests: ['Cooking', 'Reading', 'Technology', 'Travel', 'Gaming'],
    distanceKm: 8.2,
    lastActive: DateTime.now().subtract(const Duration(hours: 2)),
    profession: 'Software Engineer',
    isMatched: true, // Pre-matched for demo
    isLiked: true,
  ),
  Character(
    id: '3',
    name: 'Sophia',
    description:
        'Artist and dog lover 🎨🐕 Always up for gallery visits, long walks, and meaningful conversations.',
    imageUrl:
        'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=400',
    age: 26,
    location: 'Los Angeles, CA',
    interests: ['Art', 'Dogs', 'Museums', 'Wine', 'Music'],
    distanceKm: 15.7,
    lastActive: DateTime.now().subtract(const Duration(days: 1)),
    profession: 'Graphic Designer',
    isBookmarked: true,
  ),
  Character(
    id: '4',
    name: 'Michael',
    description:
        'Fitness enthusiast and entrepreneur. When I\'m not at the gym, you\'ll find me trying new restaurants or planning my next trip.',
    imageUrl:
        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=400',
    age: 30,
    location: 'Miami, FL',
    interests: ['Fitness', 'Business', 'Food', 'Travel', 'Beach'],
    distanceKm: 45.3,
    lastActive: DateTime.now().subtract(const Duration(hours: 6)),
    profession: 'Entrepreneur',
  ),
  Character(
    id: '5',
    name: 'Olivia',
    description:
        'Medical student with a passion for helping others. Love dancing, cooking international cuisine, and weekend adventures.',
    imageUrl: 'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=400',
    age: 24,
    location: 'Boston, MA',
    interests: ['Medicine', 'Dancing', 'Cooking', 'Volunteering', 'Books'],
    distanceKm: 12.8,
    lastActive: DateTime.now().subtract(const Duration(days: 3)),
    profession: 'Medical Student',
    isMatched: true, // Pre-matched for demo
    isLiked: true,
  ),
  Character(
    id: '6',
    name: 'David',
    description:
        'Musician and teacher who loves live concerts, outdoor activities, and deep conversations over good wine.',
    imageUrl:
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=400',
    age: 29,
    location: 'Austin, TX',
    interests: ['Music', 'Teaching', 'Wine', 'Concerts', 'Nature'],
    distanceKm: 23.1,
    lastActive: DateTime.now().subtract(const Duration(hours: 12)),
    profession: 'Music Teacher',
    isLiked: true,
  ),
];
