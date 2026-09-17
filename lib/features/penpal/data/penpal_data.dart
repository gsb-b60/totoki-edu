import '../models/penpal_friend.dart';
import '../models/letter_stage.dart';

class PenpalData {
  static List<PenpalFriend> get friends => [
        const PenpalFriend(
          id: 'history',
          name: 'Arthur Pendleton',
          subject: 'History',
          location: 'Oxford, United Kingdom',
          description:
              'A retired professor of antiquities at Oxford. Arthur enjoys exploring civilizational decline and cultural trading routes.',
          initialLetter:
              'Greetings from Oxford,\n\nI am delighted to begin this correspondence. I find that the speed of modern communications has rather diluted the rigor of intellectual discourse. Let us dedicate our letters to exploring history\'s deepest trends.\n\nTo begin, I have been revisiting Gibbon\'s views on the Roman Empire. Let me know your thoughts: what is your interpretation of why Rome collapsed? Was it primarily internal moral decay, or external barbarian migrations? Write to me, my friend.',
        ),
        const PenpalFriend(
          id: 'physics',
          name: 'Dr. Lena Voss',
          subject: 'Physics',
          location: 'Heidelberg, Germany',
          description:
              'A research astrophysicist studying relativity and space-time curvature. Lena looks for a rigorous partner to debate physics.',
          initialLetter:
              'Hello from Heidelberg,\n\nI hope this letter finds you well. I rarely write physical letters, but there is something pleasant about slowing down to discuss cosmology. I recently delivered a lecture on quantum entanglement to a cohort of bewildered undergraduates.\n\nTwo particles, separated by inconceivable distances, yet irrevocably correlated — as though the universe maintains a clandestine ledger. How do you interpret this non-local connection? Does it intrigue you, or strike you as mere mathematical abstraction? I await your theory.',
        ),
        const PenpalFriend(
          id: 'cs',
          name: 'Ada Lovelace Jr.',
          subject: 'Computer Science',
          location: 'Boston, USA',
          description:
              'A theoretical computer scientist exploring computational boundaries and zero-knowledge cryptographic systems.',
          initialLetter:
              'Hello Friend,\n\nI\'m writing this from a quiet coffee shop in Boston. Lately, I\'ve been pondering the limitations of our computational models. We live in an era where software feels all-powerful, but mathematically, the boundaries are strict.\n\nI would love to hear your thoughts on Alan Turing\'s legacy. How do you view the halting problem and the concept of undecidability in computation? Let\'s dive into the limits of what can be computed.',
        ),
      ];

  static Map<String, List<LetterStage>> get stages => {
        'history': [
          const LetterStage(
            stageNumber: 1,
            incomingLetter:
                'I have received your letter with great interest. The decline of Rome is indeed a multifaceted phenomenon. Let us move to another turning point of human history: the Industrial Revolution.\n\nIt is fascinating how steam power and mechanization reshaped agrarian societies. How do you analyze the societal transition toward urbanization and the growth of modern capitalism? I look forward to your perspective.',
            requiredKeywords: [
              'urbanization',
              'steam',
              'mechanization',
              'labor',
              'capitalism'
            ],
            keywordRegex:
                r'(?=[\s\S]*\burbaniz\w*\b)(?=[\s\S]*\bsteam\b)(?=[\s\S]*\bmechaniz\w*\b)(?=[\s\S]*\blabor\w*\b)(?=[\s\S]*\bcapitalis\w*\b)',
            successReply:
                'Arthur replies:\nYour analysis of industrial labor dynamics and steam-driven urbanization was absolutely superb. It is rare to find such clarity on historical capitalism. Let us continue.',
            failHint:
                'Arthur replies:\nI enjoyed reading your thoughts, but I would appreciate a deeper focus on the shift. Try writing a paragraph that clearly details how steam power and mechanization led to massive urbanization, labor changes, and the rise of capitalism.',
          ),
          const LetterStage(
            stageNumber: 2,
            incomingLetter:
                'Splendid reflections on industrialism! Now, let us venture further back. I\'ve been examining the Silk Road, the ancient network connecting East and West.\n\nIt was not merely a path for merchandise, but a conduit for ideas, philosophies, and religions. Tell me, how did these trade routes foster cultural exchange? Think of caravans, monasteries, and travelers. What is your thesis?',
            requiredKeywords: [
              'merchandise',
              'monastery',
              'exchange',
              'route',
              'caravan'
            ],
            keywordRegex:
                r'(?=[\s\S]*\bmerchandise\w*\b)(?=[\s\S]*\bmonaster\w*\b)(?=[\s\S]*\bexchange\w*\b)(?=[\s\S]*\broute\w*\b)(?=[\s\S]*\bcaravan\w*\b)',
            successReply:
                'Arthur replies:\nMarvelous! You captured the spirit of the Silk Road caravans, how monasteries became hubs of exchange, and how trade routes carried more than just physical merchandise.',
            failHint:
                'Arthur replies:\nYour letter was thoughtful, but missed key historical markers. Could you elaborate on how caravans traveled along the trade routes, passing monasteries, and fostering cultural exchange beyond mere merchandise?',
          ),
          const LetterStage(
            stageNumber: 3,
            incomingLetter:
                'My dear friend, this correspondence has been one of the highlights of my retirement.\n\nAs a final exercise, I would like you to summarize the ultimate lesson of history. Why does studying our past remain crucial for navigating the future? Present your final hypothesis. Let us make this a letter to remember.',
            requiredKeywords: [
              'history',
              'past',
              'future',
              'hypothesis',
              'lesson'
            ],
            keywordRegex:
                r'(?=[\s\S]*\bhistory\b)(?=[\s\S]*\bpast\b)(?=[\s\S]*\bfuture\b)(?=[\s\S]*\bhypothes[ie]s?\b)(?=[\s\S]*\blesson\b)',
            successReply:
                'Arthur replies:\nI am deeply moved by your letter. Your hypothesis on how the past guides our future lessons is profoundly true. Our correspondence will occupy a treasured place in my study. Farewell, my dear penpal.',
            failHint:
                'Arthur replies:\nAn interesting attempt, but let us elevate the discourse. Try writing a solid paragraph offering a clear hypothesis about how the past lessons of history shape our future.',
          ),
        ],
        'physics': [
          const LetterStage(
            stageNumber: 1,
            incomingLetter:
                'I appreciate your thoughts on non-locality. Now, let us examine the most extreme laboratory in the universe: Black Holes.\n\nI find the concept of an event horizon philosophically staggering — a boundary beyond which all information is lost. How do you view the relationship between the accretion disk, the event horizon boundary, and the potential escape of Hawking radiation? Write me a paragraph on this.',
            requiredKeywords: [
              'horizon',
              'boundary',
              'telescope',
              'radiation',
              'black hole'
            ],
            keywordRegex:
                r'(?=[\s\S]*\bhorizon\w*\b)(?=[\s\S]*\bboundar\w*\b)(?=[\s\S]*\btelescop\w*\b)(?=[\s\S]*\bradiat\w*\b)(?=[\s\S]*\bblack\s*hole\w*\b)',
            successReply:
                'Lena replies:\nSuperb physics! Your explanation of Hawking radiation escaping the boundary of a black hole\'s event horizon was mathematically and physically sound. Let\'s move on.',
            failHint:
                'Lena replies:\nYour explanation was a bit vague. Focus on describing a black hole, its event horizon boundary, the surrounding accretion disk, and how quantum effects might generate radiation.',
          ),
          const LetterStage(
            stageNumber: 2,
            incomingLetter:
                'Outstanding. Now, let us return to Albert Einstein\'s crowning achievement: General Relativity.\n\nWe know that gravity is not a Newtonian force, but the warping of spacetime. How would you describe the mechanism by which mass curves spacetime, altering the geodesic trajectory of matter and energy? Write it clearly.',
            requiredKeywords: [
              'relativity',
              'spacetime',
              'curve',
              'mass',
              'trajectory'
            ],
            keywordRegex:
                r'(?=[\s\S]*\brelativ\w*\b)(?=[\s\S]*\bspacetime\b)(?=[\s\S]*\bcurv\w*\b)(?=[\s\S]*\bmass\w*\b)(?=[\s\S]*\b(trajector\w*|geodesic\w*)\b)',
            successReply:
                'Lena replies:\nBrilliant synthesis! Mass curving spacetime, dictating the geodesic trajectory of moving bodies — you\'ve captured general relativity perfectly.',
            failHint:
                'Lena replies:\nLet us be more precise. Describe how the theory of relativity asserts that mass curves the geometry of spacetime, forcing physical trajectories (or geodesics) to bend.',
          ),
          const LetterStage(
            stageNumber: 3,
            incomingLetter:
                'We have established a wonderful intellectual rapport, my friend.\n\nFor our final letter exchange, let us write about the grand unification. Formulate a hypothesis on how we might reconcile general relativity with quantum mechanics. What is the ultimate secret of the universe? Explore this in a detailed paragraph.',
            requiredKeywords: [
              'hypothesis',
              'universe',
              'unification',
              'quantum',
              'relativity'
            ],
            keywordRegex:
                r'(?=[\s\S]*\bhypothes[ie]s?\b)(?=[\s\S]*\bunivers\w*\b)(?=[\s\S]*\bunific\w*\b)(?=[\s\S]*\bquantum\b)(?=[\s\S]*\brelativ\w*\b)',
            successReply:
                'Lena replies:\nMagnificent. Your hypothesis on quantum-gravitational unification in our universe was incredibly insightful. It has been an honor corresponding with you. Keep looking at the stars. Farewell.',
            failHint:
                'Lena replies:\nUnification remains unsolved, but your letter should at least present a coherent hypothesis on combining relativity and quantum mechanics in our universe.',
          ),
        ],
        'cs': [
          const LetterStage(
            stageNumber: 1,
            incomingLetter:
                'Your letter on Turing\'s limitations was excellent. Now, let\'s look at the modern frontier: Artificial Intelligence and Deep Learning.\n\nConsider how multi-layered neural networks learn. How do neurons adjust their synaptic weights via backpropagation using an activation function? Explain this computational magic in a coherent paragraph.',
            requiredKeywords: [
              'backpropagation',
              'neuron',
              'weight',
              'activation',
              'intelligence'
            ],
            keywordRegex:
                r'(?=[\s\S]*\bbackpropagation\b)(?=[\s\S]*\bneuron\w*\b)(?=[\s\S]*\bweight\w*\b)(?=[\s\S]*\bactivation\b)(?=[\s\S]*\bintelligence\b)',
            successReply:
                'Ada replies:\nSpot-on! Your description of backpropagation adjusting neural weights through activation functions was clear and computationally accurate. Let\'s keep going.',
            failHint:
                'Ada replies:\nI think you missed some core mechanics. Try writing a paragraph detailing how neurons update their weights via backpropagation using activation functions to build intelligence.',
          ),
          const LetterStage(
            stageNumber: 2,
            incomingLetter:
                'Excellent. Let\'s switch to the math of trust: Cryptography, specifically Zero-Knowledge Proofs.\n\nHow does a protocol allow a prover to verify the truth of an statement to a verifier without revealing any information? Ponder encryption, verification, and zero-knowledge signatures.',
            requiredKeywords: [
              'encryption',
              'verification',
              'protocol',
              'zero-knowledge',
              'signature'
            ],
            keywordRegex:
                r'(?=[\s\S]*\bencryption\b)(?=[\s\S]*\bverification\b)(?=[\s\S]*\bprotocol\b)(?=[\s\S]*\bzero-knowledge\b)(?=[\s\S]*\bsignature\w*\b)',
            successReply:
                'Ada replies:\nIncredible! You\'ve perfectly outlined the verification protocol of a zero-knowledge proof, preserving encryption without needing raw signatures.',
            failHint:
                'Ada replies:\nLet\'s refine the explanation. Describe how a zero-knowledge protocol performs verification of a signature or statement, keeping the underlying encryption intact.',
          ),
          const LetterStage(
            stageNumber: 3,
            incomingLetter:
                'We\'ve covered so much ground, my friend. This has been a truly computational journey.\n\nFor our final letter, let\'s look forward. What is your hypothesis on the future of humanity in the face of quantum computing or super-intelligence? Can we explore the universe through computation? Formulate a grand thesis.',
            requiredKeywords: [
              'hypothesis',
              'quantum',
              'computation',
              'intelligence',
              'explore'
            ],
            keywordRegex:
                r'(?=[\s\S]*\bhypothes[ie]s?\b)(?=[\s\S]*\bquantum\b)(?=[\s\S]*\bcomput\w*\b)(?=[\s\S]*\bintellig\w*\b)(?=[\s\S]*\bexplor\w*\b)',
            successReply:
                'Ada replies:\nI\'m thoroughly impressed. Your hypothesis on quantum computation and intelligence exploring new frontiers was beautiful. Thank you for this amazing correspondence. Farewell!',
            failHint:
                'Ada replies:\nTry to synthesize a clearer hypothesis about how quantum computation and advanced intelligence will help humanity explore the future.',
          ),
        ],
      };
}