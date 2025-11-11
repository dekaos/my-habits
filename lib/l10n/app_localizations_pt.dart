// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Habit Hero';

  @override
  String get myHabitsTitle => 'Meus Hábitos';

  @override
  String get buildBetterHabits => 'Construa Hábitos Melhores Juntos';

  @override
  String get welcomeBack => 'Bem-vindo de Volta!';

  @override
  String get signInToContinue => 'Entre para continuar sua jornada de hábitos';

  @override
  String get email => 'E-mail';

  @override
  String get password => 'Senha';

  @override
  String get login => 'Entrar';

  @override
  String get dontHaveAccount => 'Não tem uma conta?';

  @override
  String get signUp => 'Cadastre-se';

  @override
  String get createAccount => 'Criar Conta';

  @override
  String get joinMyHabits => 'Junte-se aos Meus Hábitos';

  @override
  String get startBuildingHabits =>
      'Comece a construir melhores hábitos com amigos';

  @override
  String get fullName => 'Nome Completo';

  @override
  String get confirmPassword => 'Confirmar Senha';

  @override
  String get alreadyHaveAccount => 'Já tem uma conta?';

  @override
  String get signIn => 'Entrar';

  @override
  String get pleaseEnterEmail => 'Por favor, insira seu e-mail';

  @override
  String get pleaseEnterValidEmail => 'Por favor, insira um e-mail válido';

  @override
  String get pleaseEnterPassword => 'Por favor, insira sua senha';

  @override
  String get passwordTooShort => 'A senha deve ter pelo menos 6 caracteres';

  @override
  String get pleaseEnterName => 'Por favor, insira seu nome';

  @override
  String get passwordsDoNotMatch => 'As senhas não correspondem';

  @override
  String get pleaseEnterHabitTitle =>
      'Por favor, insira um título para o hábito';

  @override
  String get loginFailed =>
      'Login falhou. Por favor, verifique suas credenciais.';

  @override
  String get signupFailed => 'Cadastro falhou. Por favor, tente novamente.';

  @override
  String get habits => 'Hábitos';

  @override
  String get social => 'Social';

  @override
  String get performance => 'Desempenho';

  @override
  String get profile => 'Perfil';

  @override
  String get myHabits => 'Meus Hábitos';

  @override
  String get newHabit => 'Novo Hábito';

  @override
  String get beginYourJourney => 'Comece Sua Jornada';

  @override
  String get everyGreatJourney =>
      'Toda grande jornada começa com um único passo.\n\nCrie seu primeiro hábito e comece a construir a vida que você deseja, um dia de cada vez.';

  @override
  String get smallStepsBigChanges => 'Pequenos passos, grandes mudanças';

  @override
  String get todaysJourney => 'Jornada de Hoje';

  @override
  String get upcomingHabits => 'Próximos Hábitos';

  @override
  String get dailyProgress => 'Progresso Diário';

  @override
  String habitsCompleted(int completed, int total) {
    return '$completed de $total hábitos concluídos';
  }

  @override
  String get amazingWork => 'Trabalho incrível!';

  @override
  String get keepGoing => 'Continue assim!';

  @override
  String get currentStreak => 'Sequência Atual';

  @override
  String get longestStreak => 'Maior Sequência';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias',
      one: '1 dia',
      zero: 'Sem sequência',
    );
    return '$_temp0';
  }

  @override
  String habitCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count hábitos',
      one: '1 hábito',
    );
    return '$_temp0';
  }

  @override
  String get allHabits => 'Todos os Hábitos';

  @override
  String get yourProgressToday => 'Seu Progresso Hoje';

  @override
  String get perfectDay => 'Dia perfeito! Todos os hábitos concluídos! 🎉';

  @override
  String get greatMomentum => 'Ótimo ritmo! Continue construindo!';

  @override
  String get everyStepCounts => 'Cada passo conta. Continue assim!';

  @override
  String get readyToBuildHabits => 'Pronto para construir novos hábitos?';

  @override
  String get habitTitle => 'Título do Hábito';

  @override
  String get habitTitlePlaceholder => 'ex: Exercício Matinal';

  @override
  String get description => 'Descrição';

  @override
  String get descriptionOptional => 'Descrição (opcional)';

  @override
  String get descriptionPlaceholder =>
      'Adicione mais detalhes sobre seu hábito...';

  @override
  String get selectIcon => 'Selecionar Ícone';

  @override
  String get chooseAnIcon => 'Escolha um Ícone';

  @override
  String get iconFitness => 'Fitness';

  @override
  String get iconReading => 'Leitura';

  @override
  String get iconHydration => 'Hidratação';

  @override
  String get iconSleep => 'Sono';

  @override
  String get iconEating => 'Alimentação';

  @override
  String get iconRunning => 'Corrida';

  @override
  String get iconMeditation => 'Meditação';

  @override
  String get iconYoga => 'Yoga';

  @override
  String get iconArt => 'Arte';

  @override
  String get iconMusic => 'Música';

  @override
  String get iconWork => 'Trabalho';

  @override
  String get iconStudy => 'Estudo';

  @override
  String get iconHealth => 'Saúde';

  @override
  String get iconWalking => 'Caminhada';

  @override
  String get iconCycling => 'Ciclismo';

  @override
  String get selectColor => 'Selecionar Cor';

  @override
  String get chooseColor => 'Escolha uma Cor';

  @override
  String get frequency => 'Frequência';

  @override
  String get daily => 'Diariamente';

  @override
  String get weekly => 'Semanalmente';

  @override
  String get custom => 'Personalizado';

  @override
  String get selectDays => 'Selecionar Dias';

  @override
  String get scheduledTime => 'Horário Agendado';

  @override
  String get scheduledTimeOptional => 'Horário Agendado (opcional)';

  @override
  String get selectTime => 'Selecionar Horário';

  @override
  String get shareWithFriends => 'Compartilhar com Amigos';

  @override
  String get makeHabitPublic => 'Tornar este hábito visível para amigos';

  @override
  String get letFriendsSeeProgress => 'Deixe seus amigos verem seu progresso';

  @override
  String get changingFrequencyWarning =>
      'Alterar a frequência redefinirá sua sequência e histórico de conclusão.';

  @override
  String get optional => 'Opcional';

  @override
  String get clearTime => 'Limpar horário';

  @override
  String notificationScheduledTomorrow(String time) {
    return 'Nota: Notificação agendada para amanhã às $time';
  }

  @override
  String get notificationPermissionsDenied =>
      'Permissões de notificação negadas. Você não receberá lembretes para este hábito.';

  @override
  String get save => 'Salvar';

  @override
  String get cancel => 'Cancelar';

  @override
  String get delete => 'Excluir';

  @override
  String get edit => 'Editar';

  @override
  String get editHabit => 'Editar Hábito';

  @override
  String get deleteHabit => 'Excluir Hábito';

  @override
  String get deleteHabitConfirmation =>
      'Tem certeza de que deseja excluir este hábito? Esta ação não pode ser desfeita.';

  @override
  String get deleteHabitQuestion =>
      'Tem certeza de que deseja excluir este hábito?';

  @override
  String get habitDetails => 'Detalhes do Hábito';

  @override
  String get markComplete => 'Marcar como Concluído';

  @override
  String get markAsComplete => 'Marcar como Concluído';

  @override
  String get completing => 'Concluindo... 🎉';

  @override
  String get completedToday => 'Concluído hoje! 🎉';

  @override
  String get checkIn => 'Check-in';

  @override
  String get addNoteOptional => 'Adicionar uma nota (opcional)...';

  @override
  String get addNote => 'Adicionar Nota';

  @override
  String get noteOptional => 'Nota (opcional)';

  @override
  String get notePlaceholder => 'Como foi?';

  @override
  String get current => 'Atual';

  @override
  String get best => 'Melhor';

  @override
  String get total => 'Total';

  @override
  String get recentCompletions => 'Conclusões Recentes';

  @override
  String get noCompletionsYet =>
      'Ainda sem conclusões.\nComece sua sequência hoje!';

  @override
  String get monday => 'Segunda-feira';

  @override
  String get tuesday => 'Terça-feira';

  @override
  String get wednesday => 'Quarta-feira';

  @override
  String get thursday => 'Quinta-feira';

  @override
  String get friday => 'Sexta-feira';

  @override
  String get saturday => 'Sábado';

  @override
  String get sunday => 'Domingo';

  @override
  String get mon => 'Seg';

  @override
  String get tue => 'Ter';

  @override
  String get wed => 'Qua';

  @override
  String get thu => 'Qui';

  @override
  String get fri => 'Sex';

  @override
  String get sat => 'Sáb';

  @override
  String get sun => 'Dom';

  @override
  String get noActivityYet => 'Ainda Sem Atividade';

  @override
  String get connectWithFriends =>
      'Conecte-se com amigos para ver o progresso deles\ne se manter motivado juntos!';

  @override
  String get findFriends => 'Encontrar Amigos';

  @override
  String get searchUsers => 'Pesquisar Usuários';

  @override
  String get searchByUsername => 'Pesquisar por nome de usuário ou e-mail...';

  @override
  String get addFriend => 'Adicionar Amigo';

  @override
  String get searchByName => 'Pesquisar por nome ou e-mail...';

  @override
  String friendRequestSent(String name) {
    return 'Solicitação de amizade enviada para $name';
  }

  @override
  String get searchForFriends => 'Pesquise amigos para adicioná-los!';

  @override
  String get searchForUsers => 'Pesquise usuários para adicionar como amigos';

  @override
  String get noUsersFound => 'Nenhum usuário encontrado';

  @override
  String get you => 'Você';

  @override
  String get add => 'Adicionar';

  @override
  String get pending => 'Pendente';

  @override
  String get friends => 'Amigos';

  @override
  String get friendRequests => 'Solicitações de Amizade';

  @override
  String get accept => 'Aceitar';

  @override
  String get reject => 'Rejeitar';

  @override
  String get sendMessage => 'Enviar Mensagem';

  @override
  String get viewProfile => 'Ver Perfil';

  @override
  String get removeFriend => 'Remover Amigo';

  @override
  String get removeFriendQuestion => 'Remover Amigo?';

  @override
  String removeFriendConfirmation(String name) {
    return 'Tem certeza de que deseja remover $name dos seus amigos?';
  }

  @override
  String get remove => 'Remover';

  @override
  String friendRemoved(String name) {
    return '$name removido dos amigos';
  }

  @override
  String get noFriendsYet => 'Ainda Sem Amigos';

  @override
  String get addFriendsToStayMotivated =>
      'Adicione amigos para se manter motivado juntos!\nCompartilhe progresso e celebre vitórias.';

  @override
  String streaksCount(int count) {
    return '$count sequências';
  }

  @override
  String newMessages(int count) {
    return '$count novas';
  }

  @override
  String get chat => 'Chat';

  @override
  String get typeMessage => 'Digite uma mensagem...';

  @override
  String get noMessages => 'Ainda sem mensagens';

  @override
  String get startConversation => 'Inicie uma conversa!';

  @override
  String sayHelloTo(String name) {
    return 'Diga olá para $name';
  }

  @override
  String failedToSendMessage(String error) {
    return 'Falha ao enviar mensagem: $error';
  }

  @override
  String get weeklyOverview => 'Visão Semanal';

  @override
  String get completionRate => 'Taxa de Conclusão';

  @override
  String get thisWeek => 'Esta Semana';

  @override
  String get last7Days => 'Últimos 7 Dias';

  @override
  String get statistics => 'Estatísticas';

  @override
  String get totalHabits => 'Total de Hábitos';

  @override
  String get activeHabits => 'Hábitos Ativos';

  @override
  String get bestStreak => 'Melhor Sequência';

  @override
  String get noPerformanceData => 'Ainda Sem Dados de Desempenho';

  @override
  String get startTrackingHabits =>
      'Comece a rastrear hábitos para ver seu progresso!';

  @override
  String get completions => 'Conclusões';

  @override
  String get activityHeatmap => 'Mapa de Calor';

  @override
  String get last90Days => 'Últimos 90 Dias';

  @override
  String get noActivity90Days => 'Sem atividade nos últimos 90 dias';

  @override
  String get less => 'Menos';

  @override
  String get more => 'Mais';

  @override
  String get dayTrend30 => 'Tendência de 30 Dias';

  @override
  String peak(int count) {
    return 'Pico: $count';
  }

  @override
  String get noCompletions30Days => 'Sem conclusões nos últimos 30 dias';

  @override
  String get streakInsights => 'Insights';

  @override
  String get avgStreak => 'Sequência Média';

  @override
  String get activeNow => 'Ativos Agora';

  @override
  String get topPerformingHabits => 'Top Hábitos';

  @override
  String completionsCount(int count) {
    return '$count conclusões';
  }

  @override
  String streakCount(int count) {
    return '$count sequência';
  }

  @override
  String get weeklyPattern => 'Padrão Semanal';

  @override
  String completionsTooltip(String date, int count) {
    return '$date: $count conclusões';
  }

  @override
  String get myProfile => 'Meu Perfil';

  @override
  String get editProfile => 'Editar Perfil';

  @override
  String get displayName => 'Nome de Exibição';

  @override
  String get enterDisplayName => 'Digite seu nome de exibição';

  @override
  String get displayNameEmpty => 'O nome de exibição não pode estar vazio';

  @override
  String get bio => 'Biografia';

  @override
  String get tellAboutYourself => 'Conte-nos sobre você...';

  @override
  String get emailCannotBeChanged => 'O e-mail não pode ser alterado';

  @override
  String get tapToChangePhoto => 'Toque para alterar a foto';

  @override
  String get newPhotoSelected => 'Nova foto selecionada';

  @override
  String get chooseFromGallery => 'Escolher da Galeria';

  @override
  String get takePhoto => 'Tirar uma Foto';

  @override
  String get removePhoto => 'Remover Foto';

  @override
  String get profileUpdatedSuccessfully => 'Perfil atualizado com sucesso!';

  @override
  String errorUpdatingProfile(String error) {
    return 'Erro ao atualizar perfil: $error';
  }

  @override
  String get logout => 'Sair';

  @override
  String get settings => 'Configurações';

  @override
  String get notifications => 'Notificações';

  @override
  String get noNotifications => 'Sem notificações';

  @override
  String get noNotificationsTitle => 'Sem Notificações';

  @override
  String get markAllRead => 'Marcar todas como lidas';

  @override
  String get youreAllCaughtUp => 'Você está em dia!';

  @override
  String get youreAllCaughtUpMessage =>
      'Você está em dia!\nVamos notificá-lo quando algo acontecer.';

  @override
  String get notificationDeleted => 'Notificação excluída';

  @override
  String get tapToReply => 'Toque para responder';

  @override
  String nowFriends(String name) {
    return 'Você e $name agora são amigos!';
  }

  @override
  String friendRequestDeclined(String name) {
    return 'Solicitação de amizade de $name recusada';
  }

  @override
  String errorAcceptingRequest(String error) {
    return 'Erro ao aceitar solicitação: $error';
  }

  @override
  String errorRejectingRequest(String error) {
    return 'Erro ao rejeitar solicitação: $error';
  }

  @override
  String errorOpeningChat(String error) {
    return 'Erro ao abrir chat: $error';
  }

  @override
  String get justNow => 'Agora mesmo';

  @override
  String weeksAgo(int count) {
    return '${count}sem atrás';
  }

  @override
  String friendRequestFrom(String name) {
    return '$name enviou uma solicitação de amizade';
  }

  @override
  String friendRequestAccepted(String name) {
    return '$name aceitou sua solicitação de amizade';
  }

  @override
  String habitCompletedBy(String name, String habit) {
    return '$name concluiu \"$habit\"';
  }

  @override
  String reactionReceived(String name, String emoji) {
    return '$name reagiu $emoji';
  }

  @override
  String newMessage(String name) {
    return '$name enviou uma mensagem';
  }

  @override
  String get today => 'Hoje';

  @override
  String get yesterday => 'Ontem';

  @override
  String get now => 'Agora';

  @override
  String minutesAgo(int count) {
    return '${count}min atrás';
  }

  @override
  String hoursAgo(int count) {
    return '${count}h atrás';
  }

  @override
  String daysAgo(int count) {
    return '${count}d atrás';
  }

  @override
  String get loading => 'Carregando...';

  @override
  String get error => 'Erro';

  @override
  String get tryAgain => 'Tentar Novamente';

  @override
  String get ok => 'OK';

  @override
  String get done => 'Concluído';

  @override
  String get undo => 'Desfazer';

  @override
  String get close => 'Fechar';

  @override
  String get search => 'Pesquisar';

  @override
  String get noResults => 'Nenhum resultado encontrado';

  @override
  String get react => 'Reagir';

  @override
  String get chooseReaction => 'Escolha uma Reação';

  @override
  String reactionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count reações',
      one: '1 reação',
    );
    return '$_temp0';
  }

  @override
  String get couldNotLoadUsers => 'Não foi possível carregar usuários';

  @override
  String get celebrationFitnessTitle => 'Modo Fera! 💪';

  @override
  String get celebrationFitnessSubtitle =>
      'Mais um passo para sua meta de fitness!';

  @override
  String get celebrationBookTitle => 'Rato de Biblioteca! 📚';

  @override
  String get celebrationBookSubtitle => 'Conhecimento é poder!';

  @override
  String get celebrationWaterTitle => 'Hidratado! 💧';

  @override
  String get celebrationWaterSubtitle => 'Mantenha-se refrescado e saudável!';

  @override
  String get celebrationSleepTitle => 'Bons Sonhos! 😴';

  @override
  String get celebrationSleepSubtitle => 'Descanse bem, você mereceu!';

  @override
  String get celebrationFoodTitle => 'Delicioso! 🍽️';

  @override
  String get celebrationFoodSubtitle => 'Hábitos alimentares saudáveis!';

  @override
  String get celebrationRunTitle => 'Em Movimento! 🏃';

  @override
  String get celebrationRunSubtitle =>
      'Continue correndo em direção aos seus objetivos!';

  @override
  String get celebrationMeditationTitle => 'Paz Interior! 🧘';

  @override
  String get celebrationMeditationSubtitle => 'Atenção plena alcançada!';

  @override
  String get celebrationYogaTitle => 'Namastê! 🧘‍♀️';

  @override
  String get celebrationYogaSubtitle => 'Equilíbrio e flexibilidade!';

  @override
  String get celebrationArtTitle => 'Criativo! 🎨';

  @override
  String get celebrationArtSubtitle => 'Expresse-se!';

  @override
  String get celebrationMusicTitle => 'Harmonia! 🎵';

  @override
  String get celebrationMusicSubtitle => 'Continue o ritmo!';

  @override
  String get celebrationWorkTitle => 'Produtivo! 💼';

  @override
  String get celebrationWorkSubtitle => 'Arrasando nas tarefas!';

  @override
  String get celebrationSchoolTitle => 'Inteligente! 🎓';

  @override
  String get celebrationSchoolSubtitle => 'O aprendizado nunca para!';

  @override
  String get celebrationHeartTitle => 'Saudável! ❤️';

  @override
  String get celebrationHeartSubtitle => 'Cuidando de si mesmo!';

  @override
  String get celebrationWalkTitle => 'Passo a Passo! 🚶';

  @override
  String get celebrationWalkSubtitle => 'Cada passo conta!';

  @override
  String get celebrationBikeTitle => 'Poder do Pedal! 🚴';

  @override
  String get celebrationBikeSubtitle => 'Pedalando rumo ao sucesso!';

  @override
  String get celebrationDefaultTitle => '🎉 Ótimo Trabalho! 🎉';

  @override
  String get celebrationDefaultSubtitle => 'Continue com o ótimo trabalho!';

  @override
  String habitCompleted(String habit) {
    return '$habit concluído! 🎉';
  }

  @override
  String habitMarkedIncomplete(String habit) {
    return '$habit marcado como incompleto';
  }

  @override
  String dayCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count dias',
      one: '1 dia',
    );
    return '$_temp0';
  }

  @override
  String totalCount(int count) {
    return '$count total';
  }

  @override
  String get consistency => 'Consistência';

  @override
  String get onFire => 'Arrasando! 🔥';

  @override
  String get keepBuilding => 'Continue Construindo';

  @override
  String get shareProgress => 'Compartilhar Progresso';

  @override
  String get inspireYourFriends => 'Inspire seus amigos!';

  @override
  String get dayStreak => 'Sequência de Dias';

  @override
  String get completed => 'Concluído';

  @override
  String get shareAsImage => 'Compartilhar como Imagem';

  @override
  String get generating => 'Gerando...';

  @override
  String get createShareCard => 'Crie um cartão de compartilhamento bonito';

  @override
  String get progressReport => 'Relatório de Progresso';

  @override
  String get buildingBetterHabits => 'Construindo hábitos melhores';

  @override
  String get dayStreakLabel => 'Sequência\nde Dias';

  @override
  String get bestStreakLabel => 'Melhor\nSequência';

  @override
  String get totalDoneLabel => 'Total\nConcluído';

  @override
  String get keepBuildingBetterHabits =>
      '💪  Continue construindo hábitos melhores!';

  @override
  String get myHabitsHashtag => '#MeusHábitos';

  @override
  String myHabitProgress(String habit) {
    return '🎯 Meu Progresso em $habit! #MeusHábitos';
  }

  @override
  String failedToGenerateImage(String error) {
    return 'Falha ao gerar imagem: $error';
  }
}
