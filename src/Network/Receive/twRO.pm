#########################################################################
#  OpenKore - Network subsystem
#  Copyright (c) 2006 OpenKore Team
#
#  This software is open source, licensed under the GNU General Public
#  License, version 2.
#  Basically, this means that you're allowed to modify and distribute
#  this software. However, if you distribute modified versions, you MUST
#  also distribute the source code.
#  See http://www.gnu.org/licenses/gpl.html for the full license.
#########################################################################
# twRO (Taiwan)
# Servertype overview: http://wiki.openkore.com/index.php/ServerType
package Network::Receive::twRO;

use strict;
use Time::HiRes;

use Globals;
use base qw(Network::Receive::ServerType0);
use Log qw(message warning error debug);
use Network::MessageTokenizer;
use Misc;
use Utils;
use Translation;

sub new {
	my ($class) = @_;
	my $self = $class->SUPER::new(@_);
	
	# Settings::addTableFile(Settings::getRecvPacketsFilename(),
	# loader => [\&parseRecvpackets, \%rpackets]);
	
	#new packets
	my %packets = (
		'006D' => ['character_creation_successful', 'a4 V9 v V2 v14 Z24 C6 v2 Z*', [qw(charID exp zeny exp_job lv_job opt1 opt2 option stance manner points_free hp hp_max sp sp_max walk_speed type hair_style weapon lv points_skill lowhead shield tophead midhead hair_color clothes_color name str agi vit int dex luk slot renameflag mapname)]],
		'0097' => ['private_message', 'v Z28 Z*', [qw(len privMsgUser privMsg)]],
		'082D' => ['received_characters_info', 'x2 C5 x20', [qw(normal_slot premium_slot billing_slot producible_slot valid_slot)]],
		'099B' => ['map_property3', 'v a4', [qw(type info_table)]],
		'099F' => ['area_spell_multiple2', 'v a*', [qw(len spellInfo)]], # -1
		'0A3B' => ['misc_effect', 'v a4 C v', [qw(len ID flag effect)]],
		'0A0C' => ['inventory_item_added', 'v3 C3 a8 V C2 V v', [qw(index amount nameID identified broken upgrade cards type_equip type fail expire bindOnEquipType)]],#31
		'0991' => ['inventory_items_stackable', 'v a*', [qw(len itemInfo)]],#-1
		'0A0D' => ['inventory_items_nonstackable', 'v a*', [qw(len itemInfo)]],#-1
		'0A0A' => ['storage_item_added', 'v V v C4 a8', [qw(index amount nameID type identified broken upgrade cards)]],
		'0A0B' => ['cart_item_added', 'v V v C x26 C2 a8', [qw(index amount nameID identified broken upgrade cards)]],
		'0993' => ['cart_items_stackable', 'v a*', [qw(len itemInfo)]],#-1
		'0A0F' => ['cart_items_nonstackable', 'v a*', [qw(len itemInfo)]],#-1
		'0995' => ['storage_items_stackable', 'v Z24 a*', [qw(len title itemInfo)]],#-1
		'0A10' => ['storage_items_nonstackable', 'v Z24 a*', [qw(len title itemInfo)]],#-1
		
		'094D' => ['sync_request_ex'],
		'0819' => ['sync_request_ex'],
		'0817' => ['sync_request_ex'],
		'0923' => ['sync_request_ex'],
		'0867' => ['sync_request_ex'],
		'0924' => ['sync_request_ex'],
		'087B' => ['sync_request_ex'],
		'0A5A' => ['sync_request_ex'],
		'088B' => ['sync_request_ex'],
		'088A' => ['sync_request_ex'],
		'08A2' => ['sync_request_ex'],
		'086B' => ['sync_request_ex'],
		'0366' => ['sync_request_ex'],
		'089D' => ['sync_request_ex'],
		'0281' => ['sync_request_ex'],
		'085C' => ['sync_request_ex'],
		'0897' => ['sync_request_ex'],
		'0957' => ['sync_request_ex'],
		'0871' => ['sync_request_ex'],
		'0952' => ['sync_request_ex'],
		'0944' => ['sync_request_ex'],
		'0893' => ['sync_request_ex'],
		'0939' => ['sync_request_ex'],
		'0863' => ['sync_request_ex'],
		'093A' => ['sync_request_ex'],
		'093C' => ['sync_request_ex'],
		'0919' => ['sync_request_ex'],
		'0873' => ['sync_request_ex'],
		'095B' => ['sync_request_ex'],
		'08A0' => ['sync_request_ex'],
		'085A' => ['sync_request_ex'],
		'0876' => ['sync_request_ex'],
		'0926' => ['sync_request_ex'],
		'087E' => ['sync_request_ex'],
		'0811' => ['sync_request_ex'],
		'092D' => ['sync_request_ex'],
		'0922' => ['sync_request_ex'],
		'0946' => ['sync_request_ex'],
		'07E4' => ['sync_request_ex'],
		'0955' => ['sync_request_ex'],
		'085E' => ['sync_request_ex'],
		'086E' => ['sync_request_ex'],
		'094F' => ['sync_request_ex'],
		'0935' => ['sync_request_ex'],
		'0872' => ['sync_request_ex'],
		'0367' => ['sync_request_ex'],
		'0927' => ['sync_request_ex'],
		'0966' => ['sync_request_ex'],
		'0950' => ['sync_request_ex'],
		'08A9' => ['sync_request_ex'],
		'088D' => ['sync_request_ex'],
		'0963' => ['sync_request_ex'],
		'0937' => ['sync_request_ex'],
		'087D' => ['sync_request_ex'],
		'0947' => ['sync_request_ex'],
		'02C4' => ['sync_request_ex'],
		'0933' => ['sync_request_ex'],
		'093D' => ['sync_request_ex'],
		'091F' => ['sync_request_ex'],
		'08AD' => ['sync_request_ex'],
		'0925' => ['sync_request_ex'],
		'0959' => ['sync_request_ex'],
		'0360' => ['sync_request_ex'],
		'0881' => ['sync_request_ex'],
		'092E' => ['sync_request_ex'],
		'0A68' => ['sync_request_ex'],
		'087C' => ['sync_request_ex'],
		'0921' => ['sync_request_ex'],
		'0896' => ['sync_request_ex'],
		'087A' => ['sync_request_ex'],
		'023B' => ['sync_request_ex'],
		'0875' => ['sync_request_ex'],
		'0882' => ['sync_request_ex'],
		'093E' => ['sync_request_ex'],
		'091C' => ['sync_request_ex'],
		'0945' => ['sync_request_ex'],
		'0890' => ['sync_request_ex'],
		'0931' => ['sync_request_ex'],
		'089C' => ['sync_request_ex'],
		'086F' => ['sync_request_ex'],
		'0866' => ['sync_request_ex'],
		'0869' => ['sync_request_ex'],
		'0956' => ['sync_request_ex'],
		'094C' => ['sync_request_ex'],
	);
	$self->{packet_list}{$_} = $packets{$_} for keys %packets;

	$self->{sync_ex_reply} = {
		'022D' => '0879',
		'0281' => '0866',
		'02C4' => '088E',
		'035F' => '0953',
		'0360' => '0967',
		'0364' => '089B',
		'0368' => '0887',
		'0438' => '095E',
		'07E4' => '085D',
		'0817' => '095D',
		'0835' => '085C',
		'085B' => '0815',
		'085E' => '0944',
		'0862' => '0819',
		'0863' => '0861',
		'0867' => '0876',
		'0869' => '0957',
		'086A' => '0948',
		'086F' => '0955',
		'0871' => '088F',
		'0877' => '0875',
		'087B' => '093B',
		'087E' => '0838',
		'087F' => '0961',
		'0881' => '08AA',
		'0882' => '0A6C',
		'0884' => '093A',
		'0885' => '0883',
		'088A' => '091D',
		'088C' => '085F',
		'0891' => '0880',
		'0896' => '0A5C',
		'0898' => '0362',
		'089A' => '0966',
		'089C' => '0872',
		'089D' => '086E',
		'089E' => '086D',
		'089F' => '085A',
		'08A1' => '08AC',
		'08A3' => '0888',
		'08A5' => '0811',
		'08A6' => '094B',
		'08A8' => '0369',
		'08A9' => '0965',
		'08AD' => '07EC',
		'0919' => '08A7',
		'091C' => '0946',
		'0922' => '0365',
		'0924' => '0361',
		'0925' => '0367',
		'0926' => '096A',
		'0927' => '0954',
		'0929' => '094D',
		'092B' => '0437',
		'092E' => '0942',
		'0930' => '091B',
		'0933' => '0892',
		'0934' => '0A5A',
		'0936' => '08A2',
		'0937' => '0802',
		'0938' => '023B',
		'0939' => '0917',
		'093C' => '0873',
		'093D' => '0860',
		'093E' => '094F',
		'093F' => '086C',
		'0940' => '0366',
		'0943' => '08A4',
		'0947' => '091A',
		'094E' => '0886',
		'0951' => '0870',
		'0952' => '0436',
		'0956' => '0897',
		'095A' => '0864',
		'095B' => '0865',
		'095C' => '088D',
		'095F' => '0889',
		'0960' => '094C',
		'0962' => '08AB',
		'0963' => '094A',
		'0964' => '0874',
		'0969' => '092A',
		'0A69' => '0A68',
		'0A6E' => '0890'
	};
	
	#New item type6
	$self->{nested} = {
		items_nonstackable => { # EQUIPMENTITEM_EXTRAINFO
			type6 => {
				len => 57,
				types => 'v2 C V2 C a8 l v2 x26 C',
				keys => [qw(index nameID type type_equip equipped upgrade cards expire bindOnEquipType sprite_id flag)],
			},
		},
		items_stackable => { # ITEMLIST_NORMAL_ITEM
			type6 => {
				len => 24,
				types => 'v2 C v V a8 l C',
				keys => [qw(index nameID type amount type_equip cards expire flag)],
			},
		},
	};
	
	return $self;
}

*parse_quest_update_mission_hunt = *Network::Receive::parse_quest_update_mission_hunt_v2;
*reconstruct_quest_update_mission_hunt = *Network::Receive::reconstruct_quest_update_mission_hunt_v2;

sub gameguard_request {
	my ($self, $args) = @_;

	debug "NProtect request received\n", "NProtect";
	return if ($config{NProtect} && $config{NProtect} == 0);

	if ($config{NProtect} == 1 || !$config{NProtect}) { #Re-log
		my $relogSecond = $timeout{'NProtect_relog_second'}{'timeout'} || 3; # 1 - 3 seconds
		error TF("NProtect check request received. Re-loging in %s seconds.\n", $relogSecond), 'info';
		
		#Re-logging in after random sec
		$taskManager->add(
			new Task::Chained(tasks => [
				new Task::Wait(seconds => rand(int($timeout{'NProtect_relog_delay'}{'timeout'})) + 1 || 5),
				new Task::Function(function => sub {relog(rand($relogSecond) + 1);$_[0]->setDone;})
			])
		);
	}
}

sub sync_received_characters {
	my ($self, $args) = @_;
	if (exists $args->{sync_Count}) {
		$charSvrSet{sync_Count} = $args->{sync_Count};
		$charSvrSet{sync_CountDown} = $args->{sync_Count};
	}

	if ($config{'XKore'} ne '1') {
		$messageSender->sendToServer($messageSender->reconstruct({switch => 'sync_received_characters'}));
		$charSvrSet{sync_CountDown}--;
	}
}

sub received_characters_info {
	my ($self, $args) = @_;

	$charSvrSet{normal_slot} = $args->{normal_slot} if (exists $args->{normal_slot});
	$charSvrSet{premium_slot} = $args->{premium_slot} if (exists $args->{premium_slot});
	$charSvrSet{billing_slot} = $args->{billing_slot} if (exists $args->{billing_slot});
	$charSvrSet{producible_slot} = $args->{producible_slot} if (exists $args->{producible_slot});
	$charSvrSet{valid_slot} = $args->{valid_slot} if (exists $args->{valid_slot});

	$timeout{charlogin}{time} = time;
}

sub items_nonstackable {
	my ($self, $args) = @_;
	my $items = $self->{nested}->{items_nonstackable};

	if ($args->{switch} eq '0A0D' ||# inventory
		$args->{switch} eq '0A0F' ||# cart
		$args->{switch} eq '0A10'	# storage
	) {
		return $items->{type6} ;
	}
	#Exception
	warning "items_nonstackable: unsupported packet ($args->{switch})!\n";
}

sub items_stackable {
	my ($self, $args) = @_;
	my $items = $self->{nested}->{items_stackable};

	if ($args->{switch} eq '0991' ||# inventory
		$args->{switch} eq '0993' ||# cart
		$args->{switch} eq '0995'	# storage
	) {
		return $items->{type6};
	}
	#Exception
	warning "items_stackable: unsupported packet ($args->{switch})!\n";
}

sub parse_items_nonstackable {
	my ($self, $args) = @_;
	$self->parse_items($args, $self->items_nonstackable($args), sub {
		my ($item) = @_;
		
		$item->{amount} = 1 unless ($item->{amount});
		if ($item->{flag} == 0) {
			$item->{broken} = $item->{identified} = 0;
		} elsif ($item->{flag} == 1 || $item->{flag} == 5) {
			$item->{broken} = 0;
			$item->{identified} = 1;
		} elsif ($item->{flag} == 3 || $item->{flag} == 7) {
			$item->{broken} = $item->{identified} = 1;
		} else {
			message T ("Warning: unknown flag!\n");
		}
	});
}

sub parse_items_stackable {
	my ($self, $args) = @_;
	$self->parse_items($args, $self->items_stackable($args), sub {
		my ($item) = @_;
		
		$item->{idenfitied} = $item->{identified} & (1 << 0);
		if ($item->{flag} == 0) {
			$item->{identified} = 0;
		} elsif ($item->{flag} == 1 || $item->{flag} == 3) {
			$item->{identified} = 1;
		} else {
			message T ("Warning: unknown flag!\n");
		}
	});
}

1;