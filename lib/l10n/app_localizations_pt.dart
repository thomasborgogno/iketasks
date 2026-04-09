// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get authError => 'Erro de autenticação';

  @override
  String get signInSubtitle =>
      'Organize suas tarefas por urgência e importância.';

  @override
  String get signInWithGoogle => 'Entrar com Google';

  @override
  String get googleUser => 'Usuário do Google';

  @override
  String get settings => 'Configurações';

  @override
  String get profileAndSettings => 'Perfil e configurações';

  @override
  String get signOut => 'Sair';

  @override
  String get quadrantImportantUrgent => 'Importante, urgente';

  @override
  String get quadrantImportantNotUrgent => 'Importante, não urgente';

  @override
  String get quadrantNotImportantUrgent => 'Não importante, urgente';

  @override
  String get quadrantNotImportantNotUrgent => 'Não importante, não urgente';

  @override
  String get quadrantNamePriority => 'Prioridade';

  @override
  String get quadrantNamePlan => 'Planejar';

  @override
  String get quadrantNameDelegate => 'Delegar';

  @override
  String get quadrantNameEliminate => 'Eliminar';

  @override
  String get yourEisenhowerMatrix => 'Sua matriz de Eisenhower';

  @override
  String greeting(String name) {
    return 'Olá, $name!';
  }

  @override
  String get columnView => 'Visualização em colunas';

  @override
  String get gridView => 'Visualização em grade';

  @override
  String get empty => 'Vazio';

  @override
  String get newTask => 'Nova tarefa';

  @override
  String get editTask => 'Editar tarefa';

  @override
  String get taskTitle => 'Título';

  @override
  String get taskDescription => 'Descrição';

  @override
  String get priority => 'Prioridade';

  @override
  String get important => 'Importante';

  @override
  String get urgent => 'Urgente';

  @override
  String get quadrant => 'Quadrante';

  @override
  String get category => 'Categoria';

  @override
  String get createCategory => 'Criar uma categoria';

  @override
  String get dueDate => 'Data de vencimento';

  @override
  String get removeDescription => 'Remover descrição';

  @override
  String get removeDescriptionConfirm => 'Deseja remover a descrição?';

  @override
  String get removeDueDate => 'Remover data de vencimento';

  @override
  String get removeDueDateConfirm => 'Deseja remover a data de vencimento?';

  @override
  String get deleteTask => 'Excluir tarefa';

  @override
  String get deleteTaskConfirm => 'Deseja excluir esta tarefa?';

  @override
  String get save => 'Salvar';

  @override
  String get createTask => 'Criar tarefa';

  @override
  String get delete => 'Excluir';

  @override
  String get remove => 'Remover';

  @override
  String get cancel => 'Cancelar';

  @override
  String dueDateLabel(String date) {
    return 'Vencimento: $date';
  }

  @override
  String get completedTasks => 'Tarefas concluídas';

  @override
  String get loadingError => 'Erro ao carregar';

  @override
  String get noCompletedTasks => 'Nenhuma tarefa concluída';

  @override
  String completedOn(String date) {
    return 'Concluída em $date';
  }

  @override
  String get categories => 'Categorias';

  @override
  String get categoryManagement => 'Gerenciamento de categorias';

  @override
  String get emoji => 'Emoji';

  @override
  String get categoryName => 'Nome da categoria';

  @override
  String get add => 'Adicionar';

  @override
  String get close => 'Fechar';

  @override
  String get deleteCategory => 'Excluir categoria';

  @override
  String deleteCategoryConfirm(String name) {
    return 'Excluir \"$name\"?';
  }

  @override
  String get deleteCategoryWarning =>
      'As tarefas associadas perderão sua categoria.';

  @override
  String get importFromGoogleTasks => 'Importar do Google Tasks';

  @override
  String get loadingGoogleTasks => 'Carregando tarefas do Google...';

  @override
  String get unknownError => 'Erro desconhecido';

  @override
  String get retry => 'Tentar novamente';

  @override
  String get noGoogleTasksFound => 'Nenhuma tarefa encontrada no Google Tasks.';

  @override
  String continueWithSelected(int count) {
    return 'Continuar ($count)';
  }

  @override
  String get selectAll => 'Selecionar tudo';

  @override
  String get deselectAll => 'Desmarcar tudo';

  @override
  String assignQuadrant(int assigned, int total) {
    return 'Atribuir quadrante ($assigned/$total)';
  }

  @override
  String get quadrantAssigned =>
      'Quadrante atribuído ✓ — toque em outro para alterá-lo';

  @override
  String get dragOrTapQuadrant => 'Arraste ou toque em um quadrante';

  @override
  String get previous => 'Anterior';

  @override
  String get skip => 'Pular';

  @override
  String get importTasks => 'Importar tarefas';

  @override
  String get widgetAppearance => 'Aparência do widget';

  @override
  String get theme => 'Tema';

  @override
  String get systemTheme => 'Sistema';

  @override
  String get lightTheme => 'Claro';

  @override
  String get darkTheme => 'Escuro';

  @override
  String get background => 'Fundo';

  @override
  String transparency(int percent) {
    return 'Transparência: $percent%';
  }

  @override
  String get textSize => 'Tamanho do texto';

  @override
  String get small => 'Pequeno';

  @override
  String get medium => 'Médio';

  @override
  String get large => 'Grande';

  @override
  String get textColor => 'Cor do texto';

  @override
  String get white => 'Branco';

  @override
  String get black => 'Preto';

  @override
  String get quadrants => 'Quadrantes';

  @override
  String get widgetUpdated => 'Widget atualizado.';

  @override
  String get colorRed => 'Vermelho';

  @override
  String get colorOrange => 'Laranja';

  @override
  String get colorYellow => 'Amarelo';

  @override
  String get colorGreen => 'Verde';

  @override
  String get colorBlue => 'Azul';

  @override
  String get colorIndigo => 'Índigo';

  @override
  String get colorPurple => 'Roxo';

  @override
  String get colorPink => 'Rosa';

  @override
  String get colorBrown => 'Marrom';

  @override
  String get colorGray => 'Cinza';

  @override
  String get colorTeal => 'Verde-azulado';

  @override
  String get colorCyan => 'Ciano';

  @override
  String get colorLime => 'Lima';

  @override
  String get colorAmber => 'Âmbar';

  @override
  String get colorDeepOrange => 'Laranja escuro';

  @override
  String get notificationChannelName => 'Tarefas prioritárias';

  @override
  String get notificationChannelDescription =>
      'Mostrar tarefas prioritárias da matriz de Eisenhower';

  @override
  String get createNewTask => 'Criar nova tarefa';

  @override
  String taskCount(int count) {
    return '$count tarefas';
  }

  @override
  String get persistentNotification => 'Notificação persistente';

  @override
  String get persistentNotificationDescription =>
      'Mostrar tarefas prioritárias na barra de notificações';

  @override
  String get language => 'Idioma';

  @override
  String get languageEnglish => 'Inglês';

  @override
  String get languageItalian => 'Italiano';

  @override
  String get languageSpanish => 'Espanhol';

  @override
  String get languageFrench => 'Francês';

  @override
  String get languageGerman => 'Alemão';

  @override
  String get languageChinese => 'Chinês';

  @override
  String get languagePortuguese => 'Português';

  @override
  String get languageRussian => 'Russo';

  @override
  String get languageJapanese => 'Japonês';

  @override
  String get languageArabic => 'Árabe';
}
