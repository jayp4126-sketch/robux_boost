import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_provider.dart';
import '../services/ad_service.dart';
import '../utils/constants.dart';
import '../widgets/game_reward_dialog.dart';
import '../widgets/simple_banner_ad.dart';

class TriviaScreen extends StatefulWidget {
  const TriviaScreen({super.key});

  @override
  State<TriviaScreen> createState() => _TriviaScreenState();
}

class _TriviaScreenState extends State<TriviaScreen> {
  int _currentQuestion = 0;
  int _coinsEarned = 0;
  int _timeLeft = 15;
  Timer? _timer;
  bool _answered = false;
  int? _selectedAnswer;
  final AdService _adService = AdService();

  final List<Map<String, dynamic>> _allQuestions = [
    {
      'question': 'What does ML stand for?',
      'answers': ['Machine Learning', 'Mobile Legend', 'Modern Logic', 'Master Level'],
      'correct': 0,
    },
    {
      'question': 'Which algorithm is used for classification?',
      'answers': ['K-Means', 'Decision Tree', 'PCA', 'DBSCAN'],
      'correct': 1,
    },
    {
      'question': 'What is supervised learning?',
      'answers': ['No labels', 'Learning with labeled data', 'Clustering', 'Reinforcement'],
      'correct': 1,
    },
    {
      'question': 'Which library is popular for ML in Python?',
      'answers': ['React', 'TensorFlow', 'jQuery', 'Bootstrap'],
      'correct': 1,
    },
    {
      'question': 'What is a neural network?',
      'answers': ['Database', 'Computing system inspired by brain', 'Web server', 'File system'],
      'correct': 1,
    },
    {
      'question': 'What is overfitting in ML?',
      'answers': ['Perfect model', 'Model too complex for data', 'Fast training', 'Good accuracy'],
      'correct': 1,
    },
    {
      'question': 'Which is a deep learning framework?',
      'answers': ['MySQL', 'PyTorch', 'Apache', 'Git'],
      'correct': 1,
    },
    {
      'question': 'What is regression used for?',
      'answers': ['Classification', 'Predicting continuous values', 'Clustering', 'Sorting'],
      'correct': 1,
    },
    {
      'question': 'What is a training dataset?',
      'answers': ['Test data', 'Data used to train model', 'Validation set', 'Production data'],
      'correct': 1,
    },
    {
      'question': 'Which metric measures classification accuracy?',
      'answers': ['MSE', 'F1 Score', 'R-squared', 'MAE'],
      'correct': 1,
    },
    {
      'question': 'What is feature engineering?',
      'answers': ['Building hardware', 'Creating useful features from data', 'Network design', 'UI design'],
      'correct': 1,
    },
    {
      'question': 'What is gradient descent?',
      'answers': ['Data structure', 'Optimization algorithm', 'Database query', 'Web protocol'],
      'correct': 1,
    },
    {
      'question': 'What is cross-validation?',
      'answers': ['Data cleaning', 'Model evaluation technique', 'Feature selection', 'Data collection'],
      'correct': 1,
    },
    {
      'question': 'Which is an unsupervised learning task?',
      'answers': ['Classification', 'Clustering', 'Regression', 'Prediction'],
      'correct': 1,
    },
    {
      'question': 'What is a confusion matrix?',
      'answers': ['Data table', 'Performance measurement tool', 'Neural layer', 'Loss function'],
      'correct': 1,
    },
    {
      'question': 'What is reinforcement learning?',
      'answers': ['Supervised method', 'Learning through rewards', 'Data preprocessing', 'Feature scaling'],
      'correct': 1,
    },
    {
      'question': 'What is a hyperparameter?',
      'answers': ['Model output', 'Configuration set before training', 'Training data', 'Test result'],
      'correct': 1,
    },
    {
      'question': 'What is batch normalization?',
      'answers': ['Data cleaning', 'Technique to stabilize learning', 'Loss function', 'Activation'],
      'correct': 1,
    },
    {
      'question': 'What is transfer learning?',
      'answers': ['Data transfer', 'Using pre-trained models', 'Network protocol', 'File sharing'],
      'correct': 1,
    },
    {
      'question': 'What is a loss function?',
      'answers': ['Data loss', 'Measures prediction error', 'Network layer', 'Optimizer'],
      'correct': 1,
    },
    {
      'question': 'What is dropout in neural networks?',
      'answers': ['Data loss', 'Regularization technique', 'Activation function', 'Layer type'],
      'correct': 1,
    },
    {
      'question': 'What is ensemble learning?',
      'answers': ['Single model', 'Combining multiple models', 'Data preprocessing', 'Feature selection'],
      'correct': 1,
    },
    {
      'question': 'What is the purpose of activation functions?',
      'answers': ['Data cleaning', 'Introduce non-linearity', 'Store weights', 'Normalize data'],
      'correct': 1,
    },
    {
      'question': 'What is K-Means used for?',
      'answers': ['Classification', 'Clustering', 'Regression', 'Prediction'],
      'correct': 1,
    },
    {
      'question': 'What is precision in ML?',
      'answers': ['Speed', 'True positives ratio', 'Data size', 'Model complexity'],
      'correct': 1,
    },
    {
      'question': 'What is recall in ML?',
      'answers': ['Memory usage', 'Sensitivity measure', 'Processing speed', 'Data quality'],
      'correct': 1,
    },
    {
      'question': 'What is a CNN?',
      'answers': ['News network', 'Convolutional Neural Network', 'Data structure', 'Web server'],
      'correct': 1,
    },
    {
      'question': 'What is an RNN?',
      'answers': ['Random Network', 'Recurrent Neural Network', 'Regression Model', 'Router'],
      'correct': 1,
    },
    {
      'question': 'What is data augmentation?',
      'answers': ['Data deletion', 'Artificially expanding dataset', 'Data compression', 'Data encryption'],
      'correct': 1,
    },
    {
      'question': 'What is the bias-variance tradeoff?',
      'answers': ['Data issue', 'Balance between underfitting and overfitting', 'Network speed', 'Memory usage'],
      'correct': 1,
    },
  ];
  late List<Map<String, dynamic>> _questions;

  @override
  void initState() {
    super.initState();
    _shuffleQuestions();
    _startTimer();
  }

  void _shuffleQuestions() {
    final random = Random();
    _questions = List.from(_allQuestions)..shuffle(random);
    // Take only 10 random questions
    if (_questions.length > 10) {
      _questions = _questions.sublist(0, 10);
    }
    // Shuffle answers for each question
    for (var question in _questions) {
      _shuffleAnswersForQuestion(question);
    }
  }

  void _shuffleAnswersForQuestion(Map<String, dynamic> question) {
    final random = Random();
    final answers = List<String>.from(question['answers']);
    final correctIndex = question['correct'] as int;
    final correctAnswer = answers[correctIndex];
    
    // Shuffle answers
    answers.shuffle(random);
    
    // Update question with shuffled answers
    question['answers'] = answers;
    // Find new index of correct answer
    question['correct'] = answers.indexOf(correctAnswer);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timeLeft = 15;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        if (mounted) {
          setState(() {
            _timeLeft--;
          });
        }
      } else {
        _nextQuestion();
      }
    });
  }

  void _answerQuestion(int index) {
    if (_answered || _questions.isEmpty) return;

    _timer?.cancel();

    setState(() {
      _answered = true;
      _selectedAnswer = index;
    });

    final isCorrect = index == _questions[_currentQuestion]['correct'];
    if (isCorrect) {
      setState(() {
        _coinsEarned += 5;
      });
    }

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        _nextQuestion();
      }
    });
  }

  void _nextQuestion() {
    _timer?.cancel();
    
    if (_currentQuestion < _questions.length - 1) {
      if (mounted) {
        setState(() {
          _currentQuestion++;
          _answered = false;
          _selectedAnswer = null;
        });
      }
      _startTimer();
    } else {
      _endGame();
    }
  }

  void _endGame() async {
    _timer?.cancel();
    
    final coins = _coinsEarned;

    if (!mounted) return;

    _showQuizCompleteDialog(coins);
  }

  void _showQuizCompleteDialog(int coins) {
    final gameName = '${AppStrings.currency} Quiz';
    showGameRewardDialog(
      context,
      coins: coins,
      adService: _adService,
      infoLines: [
        'Correct Answers: ${coins ~/ 5}/${_questions.length}',
        '5 coins per correct answer!',
      ],
      onCollect: () async {
        if (!mounted) return;
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        if (coins > 0) {
          await userProvider.addCoins(coins, gameName);
        }
        await userProvider.incrementGamesPlayed();
        _adService.incrementClaimCounter();
        if (mounted) {
          Navigator.pop(context);
        }
      },
      onDoubledCollect: () async {
        if (!mounted) return;
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.addCoins(coins * 2, gameName);
        await userProvider.incrementGamesPlayed();
        _adService.incrementClaimCounter();
        if (mounted) {
          Navigator.pop(context);
        }
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestion];
    
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.cardBackground,
        title: const Text('Trivia', style: TextStyle(color: AppColors.textDark)),
        iconTheme: const IconThemeData(color: AppColors.textDark),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Question ${_currentQuestion + 1}/${_questions.length}',
                    style: const TextStyle(
                      color: AppColors.textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: _timeLeft <= 5 ? AppColors.red : AppColors.purple,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '⏱️ $_timeLeft s',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Coins: ',
                      style: TextStyle(color: AppColors.grey, fontSize: 16),
                    ),
                    Text(
                      '$_coinsEarned',
                      style: const TextStyle(
                        color: AppColors.gold,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  question['question'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              Expanded(
                child: ListView.builder(
                  itemCount: 4,
                  itemBuilder: (context, index) {
                    final isCorrect = index == question['correct'];
                    final isSelected = _selectedAnswer == index;
                    
                    Color? backgroundColor;
                    Color? borderColor;
                    
                    if (_answered) {
                      if (isCorrect) {
                        backgroundColor = AppColors.green.withOpacity(0.2);
                        borderColor = AppColors.green;
                      } else if (isSelected) {
                        backgroundColor = AppColors.red.withOpacity(0.2);
                        borderColor = AppColors.red;
                      }
                    }

                    return GestureDetector(
                      onTap: () => _answerQuestion(index),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: backgroundColor ?? AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(
                            color: borderColor ?? AppColors.grey.withOpacity(0.3),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: borderColor?.withOpacity(0.2) ?? AppColors.purple.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  String.fromCharCode(65 + index),
                                  style: TextStyle(
                                    color: borderColor ?? AppColors.purple,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Text(
                                question['answers'][index],
                                style: const TextStyle(
                                  color: AppColors.textDark,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (_answered && isCorrect)
                              const Icon(Icons.check_circle, color: AppColors.green),
                            if (_answered && isSelected && !isCorrect)
                              const Icon(Icons.cancel, color: AppColors.red),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              const SimpleBannerAd(),
            ],
          ),
        ),
      ),
    );
  }
}
