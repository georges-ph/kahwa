import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kahwa/data/admin_repository.dart';
import 'package:kahwa/data/auth_repository.dart';
import 'package:kahwa/data/balance_repository.dart';
import 'package:kahwa/data/collections.dart';
import 'package:kahwa/data/donation_repository.dart';
import 'package:kahwa/data/goal_repository.dart';
import 'package:kahwa/data/user_repository.dart';

// The single instances screens talk to. They are created on first use, which
// is always after Firebase has been initialized in main().

final _collections = Collections(FirebaseFirestore.instance);

final authRepository = AuthRepository(FirebaseAuth.instance, _collections);

final userRepository = UserRepository(FirebaseAuth.instance, _collections);

final goalRepository = GoalRepository(_collections);

final donationRepository = DonationRepository(_collections, userRepository);

final balanceRepository = BalanceRepository(_collections);

final adminRepository = AdminRepository(_collections, userRepository);
